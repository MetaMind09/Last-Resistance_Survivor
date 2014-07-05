// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\OnFlamesMixin.lua    
//    
//    Created by:   Andrew Spiering (andrew@unknownworlds.com) and
//                  Andreas Urwalek (andi@unknownworlds.com)   
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

OnFlamesMixin = CreateMixin( OnFlamesMixin )
OnFlamesMixin.type = "Fire"

Shared.PrecacheSurfaceShader("cinematics/vfx_materials/burning.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/burning_view.surface_shader")
Shared.PrecacheSurfaceShader("materials/custom/burning_small.surface_shader")
Shared.PrecacheSurfaceShader("materials/custom/burning_med.surface_shader")
Shared.PrecacheSurfaceShader("materials/custom/burning_big.surface_shader")

local kBurnBigCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_big.cinematic")
local kBurnHugeCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_huge.cinematic")
local kBurnMedCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_med.cinematic")
local kBurnSmallCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_small.cinematic")
local kBurnTinyCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_tiny.cinematic")
local kBurn1PCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_1p.cinematic")
//local currentBurnState = 1

local fireCinematicTable = { }
fireCinematicTable["Hive"] = kBurnHugeCinematic
fireCinematicTable["CommandStation"] = kBurnHugeCinematic
fireCinematicTable["Clog"] = kBurnSmallCinematic
fireCinematicTable["Onos"] = kBurnBigCinematic
fireCinematicTable["MAC"] = kBurnSmallCinematic
fireCinematicTable["Drifter"] = kBurnSmallCinematic
fireCinematicTable["Sentry"] = kBurnSmallCinematic
fireCinematicTable["Egg"] = kBurnSmallCinematic
fireCinematicTable["Embryo"] = kBurnSmallCinematic

local function GetOnFireCinematic(ent, firstPerson)

    if firstPerson then
        return kBurn1PCinematic
    end
    
    return currentBurnCinematic
    
end

OnFlamesMixin.networkVars =
{
    isOnFire = "boolean",
    numStacks = string.format("integer (0 to %d)", kFlamethrowerMaxStacks),
    currentBurnState = "integer"
}

function OnFlamesMixin:__initmixin()

    self.numStacks = 0

    if Server then
    
        self.fireAttackerId = Entity.invalidId
        self.fireDoerId = Entity.invalidId
        
        self.timeBurnInit = 0
        self.timeLastStackAdded = 0
        
        self.isOnFire = false
        
        currentBurnState = 0
        
    end
    
end

function OnFlamesMixin:OnDestroy()

    if self:GetIsOnFire() then
        self:SetGameEffectMask(kGameEffect.OnFire, false)
    end
    
end

function OnFlamesMixin:SetOnFire(type)    

    if Server then    
        if Shared.GetTime() - self.timeBurnInit < 1 then
            return
        end
        self.currentBurnState = type
    
        if not self:GetCanBeSetOnFire() then
            return
        end
        
        self:SetGameEffectMask(kGameEffect.OnFire, true)
        
               
        if self.timeLastStackAdded == 0 or Shared.GetTime() - self.timeLastStackAdded > kFlamethrowerStackRate then
        
            self.timeLastStackAdded = Shared.GetTime()
            if self.numStacks < kFlamethrowerMaxStacks then
                self.numStacks = self.numStacks + 1;
            end
            
        end
        
        self.timeBurnInit = Shared.GetTime()
        self.isOnFire = true
        
    end
    
end

function OnFlamesMixin:GetIsOnFire()

    if Client then
        return self.isOnFire
    end

    return self:GetGameEffectMask(kGameEffect.OnFire)
    
end

function OnFlamesMixin:GetCanBeSetOnFire()

    if self.OnOverrideCanSetFire then
        return self:OnOverrideCanSetFire(attacker, doer)
    else
        return true
    end
  
end

local last_state = nil
function UpdateFireMaterial(self)

    if self._renderModel then        
        if self.isOnFire and not self.fireMaterial then
             
            self.fireMaterial = Client.CreateRenderMaterial()
            //self.fireMaterial2 = Client.CreateRenderMaterial()
            //self.fireMaterial:SetMaterial("cinematics/vfx_materials/burning.material")
            //self.fireMaterial:SetMaterial("materials/custom/burning_small.material")
            if self.currentBurnState == 1 then
                self.fireMaterial:SetMaterial("materials/custom/burning_small.material")  
                //self.fireMaterial2:SetMaterial("cinematics/vfx_materials/vfx_fireball_02_animated.material")
                //self.fireMaterial2:SetMaterial("materials/custom/glow_small.material")   
                
            elseif self.currentBurnState == 2 then
                self.fireMaterial:SetMaterial("materials/custom/burning_med.material")  
                //self.fireMaterial2:SetMaterial("cinematics/vfx_materials/vfx_xplo_pic_01_animated.material")  
                //self.fireMaterial:SetMaterial("cinematics/vfx_materials/vfx_fireball_03_animated_glow.material")
            elseif self.currentBurnState == 3 then
                self.fireMaterial:SetMaterial("materials/custom/burning_big.material")  
                //self.fireMaterial2:SetMaterial("cinematics/vfx_materials/vfx_fireball_01_animated.material") 
                            
            end
            self._renderModel:AddMaterial(self.fireMaterial)
            self.last_state = self.currentBurnState
            
            //self._renderModel:AddMaterial(self.fireMaterial2)
            
        elseif (not self.isOnFire and self.fireMaterial) or (self.last_state and self.last_state ~= self.currentBurnState ) then
        
            self._renderModel:RemoveMaterial(self.fireMaterial)
            Client.DestroyRenderMaterial(self.fireMaterial)
            self.fireMaterial = nil
            
            
            //self._renderModel:RemoveMaterial(self.fireMaterial2)
            //Client.DestroyRenderMaterial(self.fireMaterial2)
            //self.fireMaterial2 = nil
            
        end
        
    end
    //if self.GetOwner and self:GetOwner():isa("Player") and self:GetOwner():GetIsLocalPlayer() then
    if Client.GetLocalPlayer():GetActiveWeapon() == self then 
        local viewModelEntity = Client.GetLocalPlayer():GetViewModelEntity()
        if viewModelEntity then
        
            local viewModel = viewModelEntity:GetRenderModel()
            if viewModel and (self.isOnFire and not self.viewFireMaterial) then
            
                self.viewFireMaterial = Client.CreateRenderMaterial()   
                //self.viewFireMaterial2 = Client.CreateRenderMaterial()              
                if self.currentBurnState == 1 then
                    self.viewFireMaterial:SetMaterial("materials/custom/burning_small.material")
                    //self.viewFireMaterial2:SetMaterial("cinematics/vfx_materials/vfx_fireball_02_animated.material")
                    //self.viewFireMaterial2:SetMaterial("materials/custom/glow_small.material")
                                       
                elseif self.currentBurnState == 2 then
                    self.viewFireMaterial:SetMaterial("materials/custom/burning_med.material")
                    //self.viewFireMaterial2:SetMaterial("cinematics/vfx_materials/vfx_xplo_pic_01_animated.material") 
                    
                elseif self.currentBurnState == 3 then
                    self.viewFireMaterial:SetMaterial("materials/custom/burning_big.material")
                    //self.viewFireMaterial2:SetMaterial("cinematics/vfx_materials/vfx_fireball_01_animated.material") 
                end
                
                //self.viewFireMaterial:SetMaterial("cinematics/vfx_materials/burning_view.material")
                viewModel:AddMaterial(self.viewFireMaterial)
                //viewModel:AddMaterial(self.viewFireMaterial2)
                self.last_state = self.currentBurnState
                
            elseif viewModel and ((not self.isOnFire and self.viewFireMaterial)  or (self.last_state and self.last_state ~= self.currentBurnState)) then
            
                viewModel:RemoveMaterial(self.viewFireMaterial)
                Client.DestroyRenderMaterial(self.viewFireMaterial)
                self.viewFireMaterial = nil
                
                //viewModel:RemoveMaterial(self.viewFireMaterial2)
                //Client.DestroyRenderMaterial(self.viewFireMaterial2)
               // self.viewFireMaterial2 = nil
                
            end
            
        end
        
    end
    
end

local function SharedUpdate(self, deltaTime)

    if Client then
        UpdateFireMaterial(self)
        self:_UpdateClientFireEffects()
    end

    if not self:GetIsOnFire() then
        return
    end
    
    if Server then
    
        // stacks are applied at ComputeDamageOverride
        local damageOverTime = kBurnDamagePerStackPerSecond * deltaTime
        if self.GetIsFlameAble and self:GetIsFlameAble() then
            damageOverTime = damageOverTime * kFlameableMultiplier
        end
        
        local attacker = nil
        if self.fireAttackerId ~= Entity.invalidId then
            attacker = Shared.GetEntity(self.fireAttackerId)
        end

        local doer = nil
        if self.fireDoerId ~= Entity.invalidId then
            doer = Shared.GetEntity(self.fireDoerId)
        end   
        
        // See if we put ourselves out
        if Shared.GetTime() - self.timeBurnInit > kFlamethrowerBurnDuration then
            self:SetGameEffectMask(kGameEffect.OnFire, false)
        end
        
    end
    
end

function OnFlamesMixin:ComputeDamageOverrideMixin(attacker, damage, damageType, time) 
    
    if self:GetIsOnFire() and damageType == kDamageType.Flame then
        damage = damage + damage * self.numStacks * kFlameDamageStackWeight
    end
    
    return damage
    
end

function OnFlamesMixin:OnUpdate(deltaTime)   
    SharedUpdate(self, deltaTime)
end

function OnFlamesMixin:OnProcessMove(input)   
    SharedUpdate(self, input.time)
end

if Client then
    
    function OnFlamesMixin:_UpdateClientFireEffects()

        // Play on-fire cinematic every so often if we're on fire
        if self:GetGameEffectMask(kGameEffect.OnFire) and self.GetOwner and self:GetOwner() and self:GetOwner():GetIsAlive() and self:GetIsVisible() then
        
            // If we haven't played effect for a bit
            local time = Shared.GetTime()
            
            if not self.timeOfLastFireEffect or (time > (self.timeOfLastFireEffect + .5)) then
            
                local firstPerson = (Client.GetLocalPlayer() == self:GetOwner())
                local cinematicName = GetOnFireCinematic(self, firstPerson)
                
                if firstPerson then
                    Print("test")
                    local viewModel = self:GetViewModelEntity()
                    if viewModel then
                        Shared.CreateAttachedEffect(self, cinematicName, viewModel, Coords.GetTranslation(Vector(0, 0, 0)), "", true, false)
                    end
                else
                   // Shared.CreateEffect(self, cinematicName, self, self:GetAngles():GetCoords())
                end
                
                self.timeOfLastFireEffect = time
                
            end
            
        end
        
    end

end

function OnFlamesMixin:OnEntityChange(entityId, newEntityId)

    if entityId == self.fireAttackerId then
        self.fireAttackerId = newEntityId or Entity.invalidId
    end
    
    if entityId == self.fireDoerId then
        self.fireDoerId = newEntityId or Entity.invalidId
    end
    
end

function OnFlamesMixin:OnGameEffectMaskChanged(effect, state)

    if effect == kGameEffect.OnFire and state then
        self:TriggerEffects("fire_start")
    elseif effect == kGameEffect.OnFire and not state then
    
        self.fireAttackerId = Entity.invalidId
        self.fireDoerId = Entity.invalidId
        
        self:TriggerEffects("fire_stop")
        
        self.timeLastStackAdded         = 0
        self.numStacks                  = 0
        self.timeBurnInit               = 0 
        
        self.isOnFire = false
        
    end
    
end

function OnFlamesMixin:OnUpdateAnimationInput(modelMixin)
    PROFILE("OnFlamesMixin:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("onfire", self:GetIsOnFire())
end