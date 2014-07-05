//
// lua\Survivor_MapBlip.lua
//
//    Created by:   Lassi lassi@heisl.org
//

function MapBlip:UpdateRelevancy()

    self:SetRelevancyDistance(Math.infinity)
    
    local mask = 0
    
    if self.mapBlipType == kMinimapBlipType.Infestation or self.mapBlipType == kMinimapBlipType.InfestationDying then
        mask = bit.bor(mask, kRelevantToTeam2)
    else    
    
        if (self.mapBlipTeam == kTeam1Index and surviviorGamePhase ~= kSurvivorGamePhase.FragYourNeighbor) or self.mapBlipTeam == kTeamInvalid or self:GetIsSighted() then
            mask = bit.bor(mask, kRelevantToTeam1)
        end
        if self.mapBlipTeam == kTeam2Index or self.mapBlipTeam == kTeamInvalid or self:GetIsSighted() then
            mask = bit.bor(mask, kRelevantToTeam2)
        end
    
    end
    
    self:SetExcludeRelevancyMask( mask )

end