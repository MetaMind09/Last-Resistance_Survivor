//
//     Survivor_NS2GameRules.lua
//
// created by:  MetaMind09    (Simon Hiller_ andante09@gmx.de)
//
//




local HotReload = SurvivorBalanceHealth
if(not HotReload) then
  SurvivorBalanceHealth = {}
  ClassHooker:Mixin("SurvivorBalanceHealth")
end
    
function SurvivorBalanceHealth:OnLoad()

    ClassHooker:SetClassCreatedIn("BalanceHealth", "lua/BalanceHealth.lua") 
    self:PostHookClassFunction("BalanceHealth", "Update", "Update_Hook")
    
end



	// HEALTH AND ARMOR		
kMarineHealth = 100	kMarineArmor = 30	kMarinePointValue = 10
kJetpackHealth = 100	kJetpackArmor = 30	kJetpackPointValue = 20
kExosuitHealth = 100	kExosuitArmor = 280	kExosuitPointValue = 40

kGrenadeLauncherPointValue = 2
kShotgunPointValue = 5
kFlamethrowerPointValue = 7

kMinigunPointValue = 5
kRailgunPointValue = 5
		
kSkulkHealth = 70	kSkulkArmor = 10	kSkulkPointValue = 0    kSkulkHealthPerBioMass = 3
kGorgeHealth = 160	kGorgeArmor = 75	kGorgePointValue = 0    kGorgeHealthPerBioMass = 2
kLerkHealth = 125	kLerkArmor = 45	    kLerkPointValue = 0    kLerkHealthPerBioMass = 2
kFadeHealth = 250	kFadeArmor = 80     kFadePointValue = 0    kFadeHealthPerBioMass = 5
kOnosHealth = 900	kOnosArmor = 450	kOnosPointValue = 0    kOnosHealtPerBioMass = 25

kMarineWeaponHealth = 400
		
kEggHealth = 350	kEggArmor = 0	kEggPointValue = 0
kMatureEggHealth = 400	kMatureEggArmor = 0

kBabblerHealth = 10	kBabblerArmor = 0	kBabblerPointValue = 0
kBabblerEggHealth = 300	kBabblerEggArmor = 0	kBabblerEggPointValue = 0



if (not HotReload) then
	SurvivorBalanceHealth:OnLoad()
end
