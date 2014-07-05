//
// lua\Survivor_PointGiverMixin.lua
//
//    Created by:   Lassi lassi@heisl.org
//

//
// copy of the original NS2 PointGiverMixin 
//


if Server then
  function PointGiverMixin:OnConstruct(builder, newFraction, oldFraction)

    if not self.constructPoints then
      self.constructPoints = {}
    end

		//only reward pionts for building the power node
    if builder and builder:isa("Player") and GetAreFriends(self, builder) and self:GetClassName()=="PowerPoint" then
    
      local builderId = builder:GetId()
    
      if not self.constructPoints[builderId] then
        self.constructPoints[builderId] = 0
      end

      self.constructPoints[builderId] = self.constructPoints[builderId] + (newFraction - oldFraction)
    
    end
  end

  //no need to override: 
	//function PointGiverMixin:OnConstructionComplete()

  function PointGiverMixin:OnEntityChange(oldId, newId)
  
  end

  function PointGiverMixin:OnUpdatePlayer(deltaTime)   

    local score = self:GetScore()
    local kills = self:GetKills()
		//periodically award points in survival phase
    if self:isa("Player") and surviviorGamePhase 
			and surviviorGamePhase == kSurvivorGamePhase.Survival 
			and self:GetTeamNumber() == kTeam1Index then

			self.lastTimeSurvivalPointsGiven = self.lastTimeSurvivalPointsGiven or Shared.GetTime()
			if self.lastTimeSurvivalPointsGiven + kSurvivalSecondsPerPoint < Shared.GetTime() then
				if HasMixin(self, "Scoring") then
				  //TODO: replace w/ config value
				  self:AddScore(1,0,false)
				  self.lastTimeSurvivalPointsGiven = Shared.GetTime()
				  

                  
                         
                  if score > 1400 and self:GetUpgradeLevel() == 5 then
                         self:SetUpgradeLevel(6)
                         
              elseif score > 1100 and self:GetUpgradeLevel() == 4 then
                         self:SetUpgradeLevel(5)
           
              elseif score > 700 and self:GetUpgradeLevel() == 3 then
                         self:SetUpgradeLevel(4)
                                                 
			  elseif score > 500 and self:GetUpgradeLevel() == 2  then
                         self:SetUpgradeLevel(3) 
                         
              elseif score > 300 and self:GetUpgradeLevel() == 1 then
                         self:SetUpgradeLevel(2)
                         
              elseif score > 100 and (self:GetUpgradeLevel() == 0) then 
                         self:SetUpgradeLevel(1)  
                                          
                 end
                 
          /*        if kills < 2 and (self:GetUpgradeLevel() == 0 or self:GetUpgradeLevel() == 1 or self:GetUpgradeLevel() == 2 or self:GetUpgradeLevel() == 5 or self:GetUpgradeLevel() == 6 or self:GetUpgradeLevel() == 7) then
                         self:SetUpgradeLevel(9) 
                         
              elseif kills > 2 and (self:GetUpgradeLevel() == 0 or self:GetUpgradeLevel() == 1 or self:GetUpgradeLevel() == 2 or self:GetUpgradeLevel() == 3 or self:GetUpgradeLevel() == 5 or self:GetUpgradeLevel() == 6 or self:GetUpgradeLevel() == 7 or self:GetUpgradeLevel() == 9) then
                         self:SetUpgradeLevel(4) 
              
              elseif kills > 1 and (self:GetUpgradeLevel() == 0 or self:GetUpgradeLevel() == 1 or self:GetUpgradeLevel() == 2 or self:GetUpgradeLevel() == 4 or self:GetUpgradeLevel() == 5 or self:GetUpgradeLevel() == 6 or self:GetUpgradeLevel() == 7 or self:GetUpgradeLevel() == 9) then
                         self:SetUpgradeLevel(3)    
                         */
                  
			  end
		  end

	  end

  end
  
  
     function PointGiverMixin:PreOnKill(attacker, doer, point, direction)
    
        if self.isHallucination then
            return
        end    
    
        local totalDamageDone = self:GetMaxHealth() + self:GetMaxArmor() * 2        
        local points = self:GetPointValue()
        local resReward = self:isa("Player") and kPersonalResPerKill or 0
        
        // award partial res and score to players who assisted
        for attackerId, damageDone in pairs(self.damagePoints) do  
        
            local currentAttacker = Shared.GetEntity(attackerId)
            if currentAttacker and HasMixin(currentAttacker, "Scoring") then
                
                local damageFraction = Clamp(damageDone / totalDamageDone, 0, 1)                
                local scoreReward = points >= 1 and math.max(1, math.round(points * damageFraction)) or 0    
         
                currentAttacker:AddScore(scoreReward, resReward * damageFraction, attacker == currentAttacker)
                
                if self:isa("Player") and currentAttacker ~= attacker then
                    currentAttacker:AddAssistKill()
                end
                
            end
        
        end
        
        if self:isa("Player") and attacker and GetAreEnemies(self, attacker) then
        
            if attacker:isa("Player") then
                attacker:AddKill()
            end
            
            self:GetTeam():AddTeamResources(kKillTeamReward)
            
        end
        
    end

end
