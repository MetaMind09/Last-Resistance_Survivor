//
//     Survivor_NS2GameRules.lua
//
// created by:  MetaMind09    (Simon Hiller_ andante09@gmx.de)
//
//
local HotReload = SurvivorNS2Gamerules
if(not HotReload) then
  SurvivorNS2Gamerules = {}
  ClassHooker:Mixin("SurvivorNS2Gamerules")
end
    
function SurvivorNS2Gamerules:OnLoad()

    ClassHooker:SetClassCreatedIn("NS2Gamerules", "lua/NS2Gamerules.lua") 
    self:PostHookClassFunction("NS2Gamerules", "Update", "Update_Hook")
    
end

// Disable ScoreReset on roundstart

local function SurvivorNS2Gamerules:StartCountdown_Hook(self)
    
        self:ResetGame()
        
        self:SetGameState(kGameState.Countdown)
    //  ResetPlayerScores()
        self.countdownTime = kCountDownLength
        
        self.lastCountdownPlayed = nil
        
    end
    
    
if (not HotReload) then
	SurvivorGUIMarineHud:OnLoad()
end
