//
// lua\Survivor_NetworkMessages.lua
//
//    Created by:   Lassi lassi@heisl.org
//

local kSurvivorTestMessage =
{
    text = "string (48)"
}
Shared.RegisterNetworkMessage("SurvivorTestMessage", kSurvivorTestMessage)

local kSurvivorGamePhaseChangedMessage=
{
    survivorGamePhase = "enum kSurvivorGamePhase"
}
Shared.RegisterNetworkMessage("SurvivorGamePhaseChangedMessage", kSurvivorGamePhaseChangedMessage)

local kSurvivorSurvivalStartTimeMessage=
{
    survivalStartTime = "integer"
}
Shared.RegisterNetworkMessage("SurvivorSurvivalStartTimeMessage", kSurvivorSurvivalStartTimeMessage)

if Server then
	
    function SendSurvivorTestMessage(msg)
        Server.SendNetworkMessage("SurvivorTestMessage", {text = msg}, true)
    end
    
    function SendSurvivorGamePhaseChangedMessage(gamePhase)
        Server.SendNetworkMessage("SurvivorGamePhaseChangedMessage", {survivorGamePhase = gamePhase}, true)
    end
    
    function SendSurvivorSurvivalStartTimeMessage(startTime)
        Server.SendNetworkMessage("SurvivorSurvivalStartTimeMessage", {survivalStartTime = startTime}, true)
    end
    
elseif Client then
/*
	// Upgrade the counts for this upgrade Id.
	function GetSurvivorTestMessage(messageTable)
		text = messageTable.text
		ChatUI_AddSystemMessage( text )
        
    end
    Client.HookNetworkMessage("SurvivorTestMessage", GetSurvivorTestMessage)
    
    
    function GetSurvivorGamePhaseChangedMessage(messageTable)
        GetGUIManager():CreateGUIScript("Survivor_GUITimer")  
		gamePhase = messageTable.survivorGamePhase
		
		if(gamePhase == kSurvivorGamePhase.Survival) then
		    //add Timer to HUD
            //GetGUIManager():CreateGUIScript("Survivor_GUITimer")  
		end
    end
    Client.HookNetworkMessage("SurvivorGamePhaseChangedMessage", GetSurvivorGamePhaseChangedMessage)
*/
    function GetSurvivorSurvivalStartTimeMessage(messageTable)
        survivalStartTime = messageTable.survivalStartTime
        if(survivalStartTime > 0) then
            gameTimer = GetGUIManager():CreateGUIScript("Survivor_GUITimer")  
        elseif (gameTimer) then
            GetGUIManager():DestroyGUIScript(gameTimer)
        end
    end
    Client.HookNetworkMessage("SurvivorSurvivalStartTimeMessage", GetSurvivorSurvivalStartTimeMessage)
    
end
