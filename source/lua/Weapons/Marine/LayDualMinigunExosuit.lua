// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\LaySentry.lua
//
//    Created by:   Simon Hiller (andante09@gmx.de)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")

class 'LayDualMinigunExosuit' (Weapon)

LayDualMinigunExosuit.kMapName = "laydualminigunexosuit"

local kDropModelName = PrecacheAsset("models/marine/mine/mine_pile.model")
local kHeldModelName = PrecacheAsset("models/marine/welder/builder.model") //PrecacheAsset("models/marine/mine/mine_3p.model")

local kViewModelName = PrecacheAsset("models/marine/welder/welder_view.model") //PrecacheAsset("models/marine/mine/mine_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/welder/welder_view.animation_graph") //PrecacheAsset("models/marine/mine/mine_view.animation_graph")

local kPlacementDistance = 2

local networkVars =
{
    minesLeft = string.format("integer (0 to %d)", 1),
    droppingMine = "boolean"
}

function LayDualMinigunExosuit:OnCreate()

    Weapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    
    self.minesLeft = 2
    self.droppingMine = false
    
end

function LayDualMinigunExosuit:OnInitialized()

    Weapon.OnInitialized(self)
    
    self:SetModel(kHeldModelName)
    
end

function LayDualMinigunExosuit:GetIsValidRecipient(recipient)

    if self:GetParent() == nil and recipient and not GetIsVortexed(recipient) and recipient:isa("Marine") then
    
        local LayDualMinigunExosuit = recipient:GetWeapon(LayDualMinigunExosuit.kMapName)
        return LayDualMinigunExosuit == nil
        
    end
    
    return false
    
end

function LayDualMinigunExosuit:GetDropStructureId()
    return kTechId.DualMinigunExosuit
end

function LayDualMinigunExosuit:GetMinesLeft()
    return self.minesLeft
end

function LayDualMinigunExosuit:GetViewModelName()
    return kViewModelName
end

function LayDualMinigunExosuit:GetAnimationGraphName()
    return kAnimationGraph
end

function LayDualMinigunExosuit:GetSuffixName()
    return "dualminigunexosuit"
end

function LayDualMinigunExosuit:GetDropClassName()
    return "DualMinigunExosuit"
end

function LayDualMinigunExosuit:GetDropMapName()
    return DualMinigunExosuit.kMapName
end

function LayDualMinigunExosuit:GetHUDSlot()
    return 7
end

function LayDualMinigunExosuit:OnTag(tagName)

    PROFILE("LayDualMinigunExosuit:OnTag")
    
    ClipWeapon.OnTag(self, tagName)
    
    if tagName == "mine" then
    
        local player = self:GetParent()
        if player then
        
            self:PerformPrimaryAttack(player)
            
            if self.minesLeft == 0 then
            
                self:OnHolster(player)
                player:RemoveWeapon(self)
                player:SwitchWeapon(1)
                
                if Server then                
                    DestroyEntity(self)
                end
                
            end
            
        end
        
        self.droppingMine = false
        
    end
    
end

function LayDualMinigunExosuit:OnPrimaryAttackEnd(player)
    self.droppingMine = false
end

function LayDualMinigunExosuit:GetIsDroppable()
    return false
end

function LayDualMinigunExosuit:OnPrimaryAttack(player)

    // Ensure the current location is valid for placement.
    if not player:GetPrimaryAttackLastFrame() then
    
        local showGhost, coords, valid = self:GetPositionForStructure(player)
        if valid then
        
            if self.minesLeft > 0 then
                self.droppingMine = true
				self:PerformPrimaryAttack(player)
				self:OnHolster(player)
                player:RemoveWeapon(self)
                player:SwitchWeapon(1)
                
                if Server then                
                    DestroyEntity(self)
                end
            else
            
                self.droppingMine = false
                
                if Client then
                    player:TriggerInvalidSound()
                end
                
            end
            
        else
        
            self.droppingMine = false
            
            if Client then
                player:TriggerInvalidSound()
            end
            
        end
        
    end
    
end


local function DropStructure(self, player)

    if Server then
	
		local showGhost, coords, valid = self:GetPositionForStructure(player)
        if valid then
        
            // Create mine.
            local mine = CreateEntity(self:GetDropMapName(), coords.origin, player:GetTeamNumber())
            if mine then
                
                // Check for space
                if mine:SpaceClearForEntity(coords.origin) then
                
                    local angles = Angles()
                    angles:BuildFromCoords(coords)
                    mine:SetAngles(angles)
                    
                    player:TriggerEffects("create_" .. self:GetSuffixName())
                    
					
                    // Jackpot.
                    return true
                    
                else
                
                    player:TriggerInvalidSound()
                    DestroyEntity(mine)
                    
                end
                
            else
                player:TriggerInvalidSound()
            end
            
        else
        
            if not valid then
                player:TriggerInvalidSound()
            end
            
        end
        
    elseif Client then
        return true
    end
    
    return false
    
end

function LayDualMinigunExosuit:Refill(amount)
    self.minesLeft = amount
end

function LayDualMinigunExosuit:PerformPrimaryAttack(player)

    local success = true
    
    if self.minesLeft > 0 then
    
        player:TriggerEffects("start_create_" .. self:GetSuffixName())
        
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        
        success = DropStructure(self, player)
        
        if success then
            self.minesLeft = Clamp(self.minesLeft - 1, 0, 1)
        end
        
    end
    
    return success
    
end

function LayDualMinigunExosuit:OnHolster(player, previousWeaponMapName)

    Weapon.OnHolster(self, player, previousWeaponMapName)
    
    self.droppingMine = false
    
end

function LayDualMinigunExosuit:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    // Attach weapon to parent's hand
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
    self.droppingMine = false
    
    self:SetModel(kHeldModelName)
    
end

function LayDualMinigunExosuit:Dropped(prevOwner)

    //Weapon.Dropped(self, prevOwner)
    
    //self:SetModel(kDropModelName)
    
end

// Given a gorge player's position and view angles, return a position and orientation
// for structure. Used to preview placement via a ghost structure and then to create it.
// Also returns bool if it's a valid position or not.
function LayDualMinigunExosuit:GetPositionForStructure(player)

    local isPositionValid = false
    local foundPositionInRange = false
    local structPosition = nil
    
    local origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * kPlacementDistance
    
    // Trace short distance in front
    local trace = Shared.TraceRay(player:GetEyePos(), origin, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
    
    local displayOrigin = trace.endPoint
    
    // If we hit nothing, trace down to place on ground
    if trace.fraction == 1 then
    
        origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * kPlacementDistance
        trace = Shared.TraceRay(origin, origin - Vector(0, kPlacementDistance, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
        
    end

    
    // If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then
        
        foundPositionInRange = true
    
        if trace.entity == nil then
            isPositionValid = true
        elseif not trace.entity:isa("ScriptActor") and not trace.entity:isa("Clog") then
            isPositionValid = true
        end
        
        displayOrigin = trace.endPoint
        
        // Can not be built on infestation
        if GetIsPointOnInfestation(displayOrigin) then
            isPositionValid = false
        end
    
        // Don't allow dropped structures to go too close to techpoints and resource nozzles
        if GetPointBlocksAttachEntities(displayOrigin) then
            isPositionValid = false
        end
    
        // Don't allow placing above or below us and don't draw either
        local structureFacing = player:GetViewAngles():GetCoords().zAxis

        if math.abs(Math.DotProduct(trace.normal, structureFacing)) > 0.9 then
            structureFacing = trace.normal:GetPerpendicular()
        end
		
		if trace.normal:DotProduct(Vector(0, 1, 0)) < .5 then
			isPositionValid = false
		end
        // Coords.GetLookIn will prioritize the direction when constructing the coords,
        // so make sure the facing direction is perpendicular to the normal so we get
        // the correct y-axis.
        local perp = Math.CrossProduct(trace.normal, structureFacing)
        structureFacing = Math.CrossProduct(perp, trace.normal)
    
        structPosition = Coords.GetLookIn(displayOrigin, structureFacing, trace.normal)
        
    end
    
    return foundPositionInRange, structPosition, isPositionValid
    
end

function LayDualMinigunExosuit:GetGhostModelName()
    return LookupTechData(self:GetDropStructureId(), kTechDataModel)
end

function LayDualMinigunExosuit:OnUpdateAnimationInput(modelMixin)

    PROFILE("LayDualMinigunExosuit:OnUpdateAnimationInput")
    
    modelMixin:SetAnimationInput("activity", ConditionalValue(self.droppingMine, "primary", "none"))
    
end

if Client then

    function LayDualMinigunExosuit:OnProcessIntermediate(input)
    
        local player = self:GetParent()
        
        if player then
        
            self.showGhost, self.ghostCoords, self.placementValid = self:GetPositionForStructure(player)
            self.showGhost = self.showGhost and self.minesLeft > 0

        end
    
    end

end

function LayDualMinigunExosuit:GetShowGhostModel()
    return self.showGhost
end

function LayDualMinigunExosuit:GetGhostModelCoords()
    return self.ghostCoords
end   

function LayDualMinigunExosuit:GetIsPlacementValid()
    return self.placementValid
end

Shared.LinkClassToMap("LayDualMinigunExosuit", LayDualMinigunExosuit.kMapName, networkVars)
