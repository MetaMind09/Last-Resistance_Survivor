//
// lua\Survivor_AlienTeam.lua
//
//    Created by:   Lassi lassi@heisl.org
//

//don't spwan initail structures at game start
function AlienTeam:SpawnInitialStructures(techPoint) 
  local tower, hive = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    hive:SetFirstLogin()
    hive:SetInfestationFullyGrown()
    
    // It is possible there was not an available tower if the map is not designed properly.
    
    
    return tower, hive
    
end

function AlienTeam:GetHasAbilityToRespawn() 
    return true 
end

function AlienTeam:Update(timePassed)

    PROFILE("AlienTeam:Update")
    
    PlayingTeam.Update(self, timePassed)
    
    self:UpdateTeamAutoHeal(timePassed)
    //UpdateEggGeneration(self)
    //UpdateEggCount(self)
    //UpdateAlienSpectators(self)
    //self:UpdateBioMassLevel()
    //respawnAll(PlayingTeam)
    
    local shellLevel = GetShellLevel(self:GetTeamNumber())  
    for index, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
        alien:UpdateArmorAmount(shellLevel)
        alien:UpdateHealthAmount(math.min(12, self.bioMassLevel), self.maxBioMassLevel)
    end
    
    for index, queuedPlayer in ipairs(self:GetSortedRespawnQueue()) do
        self:RemovePlayerFromRespawnQueue(queuedPlayer)

    end
    
    //UpdateCystConstruction(self, timePassed)
    
end