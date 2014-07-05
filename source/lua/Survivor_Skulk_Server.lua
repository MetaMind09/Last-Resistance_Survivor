//
// lua\Survivor_Skulk_Server.lua
//
//    Created by:   Lassi lassi@heisl.org
//

function Skulk:InitWeapons()

    Alien.InitWeapons(self)
    
    self:GiveItem(BiteLeap.kMapName)
    self:GiveItem(Parasite.kMapName)
    
    self:SetActiveWeapon(BiteLeap.kMapName)    
        
end

function Skulk:GetTierTwoTechId()
    return kTechId.None
end

function Skulk:GetTierThreeTechId()
    return kTechId.None
end