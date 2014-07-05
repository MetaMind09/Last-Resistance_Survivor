//
// lua\Survivor_Gamerules.lua
//
//    Created by:   Lassi lassi@heisl.org
//


//round time (default 7 mins)
kRoundTime = 420
//do not send the no commander message the entire round
kSendNoCommanderMessageRate = kRoundTime + 1

//increase the points given for constructing the power node
kBuildPointValue = 10
//number of seconds a marine has to survive to score one point
kSurvivalSecondsPerPoint = 1
//dont give away PRes for frags
kPersonalResPerKill = 0

//set friendly fire factor to 100%
kFriendlyFireScalar = 1

survivalStartTime = nil
surviviorGamePhase = kSurvivorGamePhase.NotStarted
//gHUDMapEnabled = false

local kTimeToReadyRoom = 8

if (Server) then
    //if the survivor pahse of the the game has started already players have to wait 
    //until a new round begins
    function NS2Gamerules:GetCanJoinTeamNumber(teamNumber)      
        return (teamNumber == 1)
    end

    local ns2ResetGame = NS2Gamerules.ResetGame
    function NS2Gamerules:ResetGame()
        // Disable auto team balance
        Server.SetConfigSetting("auto_team_balance", nil)
        Print "ResetGame called"
       
        ns2ResetGame(self)
        
        //reset the round time on the clients
        if(SendSurvivorSurvivalStartTimeMessage) then
            SendSurvivorSurvivalStartTimeMessage(0)
        end

        self:ShowMarinesOnMap(false)
    end
    
    //friendly fire is enabled in the frag your neighbor pahse of the game
    function GetFriendlyFire() 
        return (surviviorGamePhase == kSurvivorGamePhase.FragYourNeighbor)
    end
    
    local ns2OnEntityKilled = NS2Gamerules.OnEntityKilled
    function NS2Gamerules:OnEntityKilled(targetEntity, attacker, doer, point, direction)       
        //call base method before moving the player to another team to have the right 
        //team colors displayed in the Player killed Player message
        ns2OnEntityKilled(self, targetEntity, attacker, doer, point, direction)
                
        //check if the killed entity was a marine
        if (targetEntity:isa("Player")) then
            if (targetEntity:GetTeamNumber() == 1) then

                //If the marine was the first one to get killed goto phase two:Survive!
                //this disables friendly fire
                if (surviviorGamePhase == kSurvivorGamePhase.FragYourNeighbor) then
                  //move on to normal game (phase 2)
                  self:SetSurvivorGamePhase(kSurvivorGamePhase.Survival)

								elseif (surviviorGamePhase == kSurvivorGamePhase.Survival) then
								  //send "Player has muted" message to clients
				          SendSurvivorTeamMessage(self.team1, kSurvivorTeamMessageTypes.PlayerMutated, targetEntity:GetId())

                end
                
            end
        end
    end
    
    function NS2Gamerules:SetSurvivorGamePhase(gamePhase)
        Print (string.format("Game phase %s has started", kSurvivorGamePhase))
        if (gamePhase == kSurvivorGamePhase.NotStarted) then
            self:OnStartNotStartedPhase()
        elseif (gamePhase == kSurvivorGamePhase.FragYourNeighbor) then
            self:OnStartFragYourNeighborPhase()
        elseif (gamePhase == kSurvivorGamePhase.Survival) then
            self:OnStartSurvivalPhase()
        end
        
        surviviorGamePhase = gamePhase
        SendSurvivorGamePhaseChangedMessage(gamePhase)
    end
    
    function NS2Gamerules:GetSurvivorGamePhase()
        return surviviorGamePhase    
    end
    
    function NS2Gamerules:OnStartNotStartedPhase()
    end
    
    function NS2Gamerules:OnStartFragYourNeighborPhase()
    end
    
    function NS2Gamerules:OnStartSurvivalPhase()
			  //re-enable minimap
        self:ShowMarinesOnMap(true)
			  //Notify the players that it's time to survive
				SendSurvivorTeamMessage(self.team1, kSurvivorTeamMessageTypes.SurvivalStarted)
        //start round timer
        survivalStartTime = Shared.GetTime()
        //send the survival phase starting timestamp to the clients
        SendSurvivorSurvivalStartTimeMessage(survivalStartTime)
        
        //restore marine health and armor
        self.team1:RestoreTeamHealth()
        
        //socket one random power node
        self:DropRandomPowerPoint()
        
        //turn off the lights
        for _, entity in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
            if(entity)then
                entity:SetLightMode(kLightMode.NoPower)
            end
        end
        
        //play power out sound
        //self:PlaySound(kDestroyedSound)
        //self:PlaySound(kDestroyedPowerDownSound)
    end
    
    // start the game as soon as all players have joined marines
    function NS2Gamerules:CheckGameStart()
        local team1Players = self.team1:GetNumPlayers()
        local totalPlayers = Server.GetNumPlayers()
        
        if ((team1Players < totalPlayers) or (totalPlayers == 0)) then
            //TODO: print a message that all players have to join marine for the game to start
            
            //debug message
            /*local msg = "Players on server: %d; Players in Marine Team: %d"
            msg = string.format(msg, totalPlayers, team1Players)
            Print (msg)
            */
            return
        end
                //start the game already!
        if self:GetGameState() == kGameState.NotStarted then
            self.countdownTime = 1
            self:SetGameState(kGameState.PreGame)
            self:SetSurvivorGamePhase(kSurvivorGamePhase.FragYourNeighbor)
        end
    end
    
    // the game ends when: all players are aliens 
    //                     the time is up
    function NS2Gamerules:CheckGameEnd()    
        if (self:GetGameStarted() and self.timeGameEnded == nil and not self.preventGameEnd) then
            if (self.timeLastGameEndCheck == nil or (Shared.GetTime() > self.timeLastGameEndCheck + 1)) then
                local team1Players = self.team1:GetNumPlayers()
                local team2Players = self.team2:GetNumPlayers()
                
                if (team1Players == 0) then
                    self:SetSurvivorGamePhase(kSurvivorGamePhase.NotStarted)
                    self:EndGame(self.team2)
                end
                
                //check if time is up
                if (surviviorGamePhase == kSurvivorGamePhase.Survival) and
                   (Shared.GetTime() > survivalStartTime + kRoundTime) then
                   self:SetSurvivorGamePhase(kSurvivorGamePhase.NotStarted)
                   self:EndGame(self.team1)
                end
            end
        end
    end
    
    
    function NS2Gamerules:ShowMarinesOnMap(show)
        local playerIds = self.team1.playerIds
        
        for _, playerId in ipairs(playerIds) do     
            local player = Shared.GetEntity(playerId)
            
            if player ~= nil and player:GetId() ~= Entity.invalidId and player:GetIsAlive() then
							  if show then
									player:UpdateClientRelevancyMask()
								else
 					        local client = Server.GetOwner(player)
 					        // client may be nil if the server is shutting down.
 					        if client then
 					            client:SetRelevancyMask(kRelevantToReadyRoom)
 					        end
							  end	
            end
        end
    end
    
    //unlock the tech tree so we can give upgrades to players 
    //simply by calling GiveUpgrade
    function NS2Gamerules:GetAllTech()
        return true
    end
    
    function NS2Gamerules:DropRandomPowerPoint()
        //find all power nodes
        local powerPoints = Shared.GetEntitiesWithClassname("PowerPoint")
        
        //randomly select the one that can be repared
        local powerPointRandomizer = Randomizer()
        powerPointRandomizer:randomseed(Shared.GetSystemTime()) 
        local repairablePowerPointIndex = powerPointRandomizer:random(1,powerPoints:GetSize())
        local repairablePowerPoint = powerPoints:GetEntityAtIndex(repairablePowerPointIndex - 1)
        
        //socket power node
        //repairablePowerPoint:SetInternalPowerState(PowerPoint.kPowerState.destroyed)
        repairablePowerPoint:SocketPowerNode()
        Print(string.format("Repairable PowerPoint is in %s", repairablePowerPoint:GetLocationName()))
        
        //add ConstructionComplete event listener
        repairablePowerPoint:GetTeam():AddListener("OnConstructionComplete",function(structure)
            if(structure == repairablePowerPoint) then
                Print "Repairable PowerPoint constructed!"
                //turn on the lights
                for _, entity in ientitylist(powerPoints) do
                    if(entity ~= repairablePowerPoint) then
                        entity:SetLightMode(kLightMode.Normal)
                    end
                end 
            end
        end)
        
        //add Kill event listener
        local repairablePowerPoint_OnKill = repairablePowerPoint.OnKill
        repairablePowerPoint.OnKill = function(self, attacker, doer, point, direction)
            //turn off the lights
            for _, entity in ientitylist(powerPoints) do
                if(entity ~= repairablePowerPoint) then
                    entity:SetLightMode(kLightMode.NoPower)
                end
            end 
            
            //call original event handler
            repairablePowerPoint_OnKill(self, attacker, doer, point, direction)
        end
        
    end
		
		local ns2OnUpdate=NS2Gamerules.OnUpdate
    function NS2Gamerules:OnUpdate(timePassed)
			  //disable NO COMMANDER nagging by resetting the last checked field for both teams before calling 
				//the original Update function
				if(self.noCommanderStartTime) then
				    self.noCommanderStartTime["MarineCommander"] = nil
				    self.noCommanderStartTime["AlienCommander"] = nil
				end

				//call original function
				ns2OnUpdate(self, timePassed)
		end
	
		//since this function overrides the original implementation we can't change
		//the name although we dont update to ready room at all...
    function NS2Gamerules:UpdateToReadyRoom()

        local state = self:GetGameState()
        if(state == kGameState.Team1Won or state == kGameState.Team2Won or state == kGameState.Draw) then
        
            if self.timeSinceGameStateChanged >= kTimeToReadyRoom then
            
                // since we want the game to restart immediatly 
								// we move all the player straigt back into the marine team
                local function SetReadyRoomTeam(player)
                    player:SetCameraDistance(0)
                    self:JoinTeam(player, kTeam1Index)
                end
                Server.ForAllPlayers(SetReadyRoomTeam)

                // Spawn them there and reset teams
                self:ResetGame()

            end
            
        end
        
    end
		
   
end
