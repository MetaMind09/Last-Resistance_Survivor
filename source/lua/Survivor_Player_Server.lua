



function TechUnlocker()



    local team1PlayerCount = GetGamerules():GetTeam(kTeam1Index):GetNumPlayers()
    local team2PlayerCount = GetGamerules():GetTeam(kTeam2Index):GetNumPlayers()
    local allplayers =  team1PlayerCount + team2PlayerCount
    local marinepercentage = (team1PlayerCount/allplayers)*100

    local MarineUpgrade

    local marinetechtree = GetTechTree(kTeam1Index)
    if marinepercentage < 20 then
        //Print ("20")
        if first_20 then
            GetGamerules():GetTeam(kTeam1Index):PlayPrivateTeamSound(Player.kupgrade_complete)
            //GetGamerules():GetTeam(kTeam2Index):PlayPrivateTeamSound(Player.kupgrade_complete)
            first_20 = false
            first_50 = true
            first_80 = true
        end
        //marinetechtree:GetTechNode(kTechId.Armor3):SetResearched(true)
        marinetechtree:GetTechNode(kTechId.Weapons3):SetResearched(true)
    elseif marinepercentage < 50 then
         if first_50 then
            GetGamerules():GetTeam(kTeam1Index):PlayPrivateTeamSound(Player.kupgrade_complete)
            //GetGamerules():GetTeam(kTeam2Index):PlayPrivateTeamSound(Player.kupgrade_complete)
            first_20 = true
            first_50 = false
            first_80 = true
        end
        //Print ("50")
        //marinetechtree:GetTechNode(kTechId.Armor2):SetResearched(true)
        marinetechtree:GetTechNode(kTechId.Weapons2):SetResearched(true)
    elseif marinepercentage < 80 then
        if first_80 then
            GetGamerules():GetTeam(kTeam1Index):PlayPrivateTeamSound(Player.kupgrade_complete)
            //GetGamerules():GetTeam(kTeam2Index):PlayPrivateTeamSound(Player.kupgrade_complete)
            first_20 = true
            first_50 = true
            first_80 = false
        end
        //Print ("80")
        //marinetechtree:GetTechNode(kTechId.Armor1):SetResearched(true)
        marinetechtree:GetTechNode(kTechId.Weapons1):SetResearched(true)
    else 
        first_20 = true
        first_50 = true
        first_80 = true 
    end      
    marinetechtree:SetTechChanged()

end


local function UpdateChangeToSpectator(self)

    if not self:GetIsAlive() and not self:isa("Spectator") then
    
        local time = Shared.GetTime()
        if self.timeOfDeath ~= nil and (time - self.timeOfDeath > kFadeToBlackTime) then
        
            // Destroy the existing player and create a spectator in their place (but only if it has an owner, ie not a body left behind by Phantom use)
            local owner = Server.GetOwner(self)
            if owner then
            
                // Queue up the spectator for respawn.
                local spectator = self:Replace(self:GetDeathMapName())
                spectator:GetTeam():PutPlayerInRespawnQueue(spectator)
                TechUnlocker()
            end
            
        end
        
    end
    
end

function Player:OnUpdatePlayer(deltaTime)

    UpdateChangeToSpectator(self)
    
    local gamerules = GetGamerules()
    self.gameStarted = gamerules:GetGameStarted()
    if self:GetTeamNumber() == kTeam1Index or self:GetTeamNumber() == kTeam2Index then
        self.countingDown = gamerules:GetCountingDown()
    else
        self.countingDown = false
    end
    
end