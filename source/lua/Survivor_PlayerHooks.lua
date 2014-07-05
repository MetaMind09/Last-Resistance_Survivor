//
// lua\Survivor_PlayerHooks.lua
//
//    Created by:   Lassi lassi@heisl.org
//
//TODO: Just for reference - implement or remove this file!
if Server then  

  local HotReload = SurvivorPlayer
  if(not HotReload) then
    SurvivorPlayer = SurvivorPlayer or {}
    ClassHooker:Mixin("SurvivorPlayer")
  end
  
  function SurvivorPlayer:OnLoad()
    ClassHooker:SetClassCreatedIn("Player", "lua/Player.lua") 
    self:PostHookClassFunction("Player", "OnUpdatePlayer", "OnUpdatePlayer_Hook")
  end
  
  function SurvivorPlayer:OnUpdatePlayer_Hook(player, deltaTime)
		//throw new NotImplementedException() ;)
  end
  
  
  
  if (not HotReload) then
  	SurvivorPlayer:OnLoad()
  end

end
