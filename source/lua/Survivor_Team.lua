//
// lua\Survivor_Team.lua
//
//    Created by:   Lassi lassi@heisl.org
//

local function refillAmmoForPlayer(player)
    // Give ammo to all their weapons, one clip at a time, starting from primary
    local weapons = player:GetHUDOrderedWeaponList()
    
    for index, weapon in ipairs(weapons) do
        if weapon:isa("ClipWeapon") then
					  local clipsToGive = (weapon:GetMaxAmmo() - weapon:GetAmmo()) / weapon:GetClipSize()
            weapon:GiveAmmo(clipsToGive, false)
        end
    end
end	

function Team:RestoreTeamHealth()
    local playerIds = self.playerIds
    
    for _, playerId in ipairs(playerIds) do     
        local player = Shared.GetEntity(playerId)
        
        if player ~= nil and player:GetId() ~= Entity.invalidId and player:GetIsAlive() then
            //max health gets clamped 
            player:SetHealth(9999)
            player:SetArmor(9999, false)
						refillAmmoForPlayer(player)
        end
    end
end

