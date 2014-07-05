// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ResourcePoint.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/ObstacleMixin.lua")

class 'ResourcePoint' (ScriptActor)

ResourcePoint.kPointMapName = "resource_point"

local kEffect = PrecacheAsset("cinematics/common/resnode.cinematic")
local kIdleSound = PrecacheAsset("sound/NS2.fev/common/resnode_idle")

ResourcePoint.kModelName = PrecacheAsset("models/misc/resource_nozzle/resource_nozzle.model")

local networkVars =
{
    playingEffect = "boolean",
    showObjective = "boolean",
    occupiedTeam = string.format("integer (-1 to %d)", kSpectatorIndex),
    attachedId = "entityid",
}
    
if Server then
    Script.Load("lua/ResourcePoint_Server.lua")
end

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
/*
if Server then
    

    ResourcePoint.lastpickup = 0
    ResourcePoint.ammopack_id = 0
    ResourcePoint.ammopack_lt = 0
    ResourcePoint.medpack_id = 0
    ResourcePoint.medpack_lt = 0
    ResourcePoint.ammo_pos = 0
    ResourcePoint.med_pos = 0 
    function ResourcePoint:dropSupplyPacks()  
        self.ammo_pos =  self:GetOrigin()+ Vector(0.3,0.5,0)
        self.med_pos =   self:GetOrigin()+ Vector(-0.3,0.5,0)       
        if self.ammopack_id == 0 or (Shared.GetEntity( self.ammopack_id ) == nil and Shared.GetTime() - self.ammopack_lt >= kLRconfig.kSupplyRespawnTime )then             
        local ammopack = CreateEntity("ammopack", self.ammo_pos, kTeam1Index)                       
            self.ammopack_id = ammopack:GetId()           
            ammopack.physicsModel:SetGravityEnabled(false) 
            ammopack.physicsModel:SetCollisionEnabled(false)
            ammopack.GetIsPermanent = true            
            self.ammopack_lt = 0
        end 
         if self.medpack_id == 0 or (Shared.GetEntity( self.medpack_id ) == nil and Shared.GetTime() - self.medpack_lt >= kLRconfig.kSupplyRespawnTime) then            
            local medpack = CreateEntity("medpack", self.med_pos, kTeam1Index) 
            self.medpack_id = medpack:GetId()               
            medpack.physicsModel:SetGravityEnabled(false) 
            medpack.physicsModel:SetCollisionEnabled(false)
            medpack.GetIsPermanent = true
            self.medpack_lt = 0
        end  
                  
    end
    
    function ResourcePoint:OnUpdateDropPosition(deltatime) 
        self.ammo_pos =  self:GetOrigin()+ Vector(0.3,0.5,0)
        self.med_pos =   self:GetOrigin()+ Vector(-0.3,0.5,0)
        if self.ammopack_id ~= 0 then
            local ammopack = Shared.GetEntity( self.ammopack_id )
            if ammopack ~= nil then                
                local tcoords = ammopack.physicsModel:GetCoords()
                tcoords.origin= self.ammo_pos
                ammopack.physicsModel:SetCoords(tcoords)                
                ammopack.physicsModel:SetLinearVelocity(Vector(0, 0, 0))
            elseif self.ammopack_lt == 0 then 
                self.ammopack_lt = Shared.GetTime() 
            end
        end
        
        if self.medpack_id ~= 0 then
            local medpack = Shared.GetEntity( self.medpack_id )
            if medpack ~= nil then
                local tcoords = medpack.physicsModel:GetCoords()
                tcoords.origin= self.med_pos
                medpack.physicsModel:SetCoords(tcoords)                
                medpack.physicsModel:SetLinearVelocity(Vector(0, 0, 0))                     
            elseif self.medpack_lt == 0 then
                self.medpack_lt = Shared.GetTime() 
            end
        end
          
    end
end
*/

function ResourcePoint:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, ObstacleMixin)

    if Client then
        InitMixin(self, CommanderGlowMixin)   
        self.resnodeEffectPlaying = false
    end
    
    // Anything that can be built upon should have this group
    self:SetPhysicsGroup(PhysicsGroup.AttachClassGroup)
    
    // Make the nozzle kinematic so that the player will collide with it.
    self:SetPhysicsType(PhysicsType.Kinematic)
    
    self:SetTechId(kTechId.ResourcePoint)
    
end

function ResourcePoint:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(ResourcePoint.kModelName)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self:SetRelevancyDistance(Math.infinity)
        self:SetExcludeRelevancyMask(bit.bor(kRelevantToTeam1, kRelevantToTeam2))
        
        self.showObjective = false
        self.occupiedTeam = 0
    elseif Client then
        InitMixin(self, UnitStatusMixin)     
    end
    
end

function ResourcePoint:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end


function ResourcePoint:Reset()
    
    self:OnInitialized()
    
    self:ClearAttached()
    
    local locationName = self:GetLocationName()
    if locationName == nil or locationName == "" then
        Print("Resource point at %s isn't in a valid location (\"%s\", it won't be socketed)", ToString(locationName), ToString(self:GetOrigin()))
    end
    
end

if Client then

    function ResourcePoint:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        // changed this to check for attached entity, instead of controlling the effect serverside
        local attached = self:GetAttached()
        
        local playEffect = not attached or (not attached:GetIsVisible())
        
        if not playEffect and self.resnodeEffectPlaying then
        
            self:DestroyAttachedEffects()
            self:StopSound(kIdleSound)
            self.resnodeEffectPlaying = false
            
        elseif playEffect and not self.resnodeEffectPlaying then
        
            self:AttachEffect(kEffect, self:GetCoords())
            self:PlaySound(kIdleSound)
            self.resnodeEffectPlaying = true
            
        end

    end
    
end

function ResourcePoint:GetHealthbarOffset()
    return 0.6
end 

Shared.LinkClassToMap("ResourcePoint", ResourcePoint.kPointMapName, networkVars)