//
// lua\Survivor_GUIMarineHud.lua
//
//    Created by:   Lassi lassi@heisl.org
//
//NOTE: this file originated as a copy of combat_GUIMarineHud.lua from the NS2 Combat Mod
//      by JimWest and MCMLXXXIV, 2012
//

local HotReload = SurvivorGUIMarineHud
if(not HotReload) then
  SurvivorGUIMarineHud = {}
  ClassHooker:Mixin("SurvivorGUIMarineHud")
end
    
function SurvivorGUIMarineHud:OnLoad()

    ClassHooker:SetClassCreatedIn("GUIMarineHUD", "lua/Hud/Marine/GUIMarineHud.lua") 
    self:PostHookClassFunction("GUIMarineHUD", "Update", "Update_Hook")
    
end

// Display a Survivor instead of commander name...
function SurvivorGUIMarineHud:Update_Hook(self, deltaTime)

	self.commanderName:DestroyAnimation("COMM_TEXT_WRITE")
	self.commanderName:SetText("Last Resistance(Survivor)")
	self.commanderName:SetColor(GUIMarineHUD.kActiveCommanderColor)

end

if (not HotReload) then
	SurvivorGUIMarineHud:OnLoad()
end
