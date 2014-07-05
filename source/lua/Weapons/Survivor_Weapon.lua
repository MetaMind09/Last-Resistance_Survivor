Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/OnFlamesMixin.lua")

AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(OnFlamesMixin, networkVars)


function Weapon:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, OnFlamesMixin)

    self:SetPhysicsGroup(PhysicsGroup.WeaponGroup)
    
    self:SetUpdates(true)
    
    self.reverseX = false
    self.isHolstered = true
    self.primaryAttacking = false
    self.secondaryAttacking = false
    
    // This value is used a lot in this class, cache it off.
    self.mapName = self:GetMapName()
    
    if Client then
        self.activeSince = 0
    end
    
end