//
//      Survivor_PlayingTeam.lua
//
//      created by:  MetaMind09    (Simon Hiller_ andante09@gmx.de)
//




function PlayingTeam:RespawnPlayer(player, origin, angles)

    local success = false
   // local initialTechPoint = Shared.GetEntity(self.initialTechPointId)
    
    if origin ~= nil and angles ~= nil then
        success = Team.RespawnPlayer(self, player, origin, angles)
    else //if initialTechPoint ~= nil then
    
        //Get Random powerPoint (ISSUE #2)
        local powerPoints = GetEntitiesMatchAnyTypes({"PowerPoint","CommandStructure","ResourcePoint","TechPoint","Door"})
        
    
        // Compute random spawn location
       local spawnOrigin = nil
        local c_powerPoint = nil
                
        /*
        //bug workaround
        Print(string.format("%s dim: %f  | %f",player:GetTeamNumber(), capsuleHeight, capsuleRadius))
        if capsuleHeight == 0 and capsuleRadius then
            capsuleHeight = 1.9
            capsuleRadius = 0.35
        end
        */
       
        //Try to find a valid spawnpoint... 40 trys
        for i = 0, 80, 1 do
            if powerPoints == nil or #powerPoints == 0 then
                spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, initialTechPoint:GetOrigin(), 2, 15, EntityFilterAll())
            else  
              
             c_powerPoint = powerPoints[math.random( #powerPoints )]
             
              if EntityToString(c_powerPoint) == "ResourcePoint" then
                    //go a little bit up                     
                    spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, c_powerPoint:GetOrigin() + Vector(0, 2, 0) , 2, 40, EntityFilterAll())
                elseif EntityToString(c_powerPoint) == "Door" then 
                    //go out of the door (door origin inside walls)                    
                    spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, c_powerPoint:GetOrigin() + Vector(0.3, 0.3, 0) , 2, 40, EntityFilterAll())
                else
                    spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, c_powerPoint:GetOrigin(), 2, 40, EntityFilterAll())
                end
            end 
            if spawnOrigin ~=nil then
                if i < 20 then 
                    if player:GetTeamNumber() == kTeam2Index then                        
                        local entl = GetEntitiesWithinRange("Marine",spawnOrigin, 40)                        
                        if #entl==0 then                               
                            break
                        end 
                    elseif player:GetTeamNumber() == kTeam1Index then
                        local entl = GetEntitiesWithinRange("Marine",spawnOrigin, 20)                        
                        if #entl==0 then                        
                            break
                        end 
                    end
                elseif i < 40 then                    
                    if player:GetTeamNumber() == kTeam2Index then                        
                        local entl = GetEntitiesWithinRange("Marine",spawnOrigin, 20)                        
                        if #entl==0 then                               
                            break
                        end 
                    elseif player:GetTeamNumber() == kTeam1Index then
                        local entl = GetEntitiesWithinRange("Marine",spawnOrigin, 8)                        
                        if #entl==0 then                        
                            break
                        end 
                    end
                else
                    Print("Couldn't find 'clean' spawn! ")            
                    break
                end
            end  
        end   

        if spawnOrigin ~= nil then
              
            // Orient player towards tech point
            local lookAtPoint = c_powerPoint:GetOrigin() + Vector(0, 5, 0)
            local toTechPoint = GetNormalizedVector(lookAtPoint - spawnOrigin)
            success = Team.RespawnPlayer(self, player, spawnOrigin, Angles(GetPitchFromVector(toTechPoint), GetYawFromVector(toTechPoint), 0))
            
        else
        
            Print("PlayingTeam:RespawnPlayer: Couldn't compute random spawn for player.\n")
            Print(Script.CallStack())
            
        end
        
   // else
   //      Print("PlayingTeam:RespawnPlayer(): No initial tech point.")
    end
    
    return success
    
end