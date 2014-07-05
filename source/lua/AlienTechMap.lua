// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienTechMap.lua
//
// Created by: Andreas Urwalek (and@unknownworlds.com)
//
// Formatted alien tech tree.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIUtility.lua")

kAlienTechMapYStart = 2
local function CheckHasTech(techId)

    local techTree = GetTechTree()
    return techTree ~= nil and techTree:GetHasTech(techId)

end

local function SetShellIcon(icon)

   

end

local function SetVeilIcon(icon)


    
end

local function SetSpurIcon(icon)    



end

kAlienTechMap =
{
                    { kTechId.UpgradeSkulk, 5.5, -0.5 },  { kTechId.UpgradeLerk, 6.5, -0.5 }, { kTechId.UpgradeFade, 7.5, -0.5 },  { kTechId.UpgradeOnos, 8.5, -0.5 }, 

                    { kTechId.Whip, 5.5, 0.5 },          { kTechId.Shift, 6.5, 0.5 },          { kTechId.Shade, 7.5, 0.5 }, { kTechId.Crag, 8.5, 0.5 }, 


                    { kTechId.Harvester, 4, 1.5 },                           { kTechId.Hive, 7, 1.5 },                         { kTechId.UpgradeGorge, 10, 1.5 }, 
  
                   { kTechId.CragHive, 4, 3 },                               { kTechId.ShadeHive, 7, 3 },                            { kTechId.ShiftHive, 10, 3 },
              { kTechId.Shell, 4, 4 },                     { kTechId.Veil, 7, 4 },                    { kTechId.Spur, 10, 4 },
  { kTechId.Carapace, 3.5, 5 },{ kTechId.Regeneration, 4.5, 5 }, { kTechId.Phantom, 6.5, 5 },{ kTechId.Aura, 7.5, 5 },{ kTechId.Celerity, 9.5, 5 },{ kTechId.Adrenaline, 10.5, 5 },
  
  { kTechId.BioMassOne, 3, 7, nil, "1" }, { kTechId.BabblerEgg, 3, 8 },
  
  { kTechId.BioMassTwo, 4, 7, nil, "2" }, {kTechId.Rupture, 4, 8},  { kTechId.ShadowStep, 4, 9 },
  
  { kTechId.BioMassThree, 5, 7, nil, "3" }, {kTechId.BoneWall, 5, 8}, {kTechId.BileBomb, 5, 9}, { kTechId.Charge, 5, 10 },

  { kTechId.BioMassFour, 6, 7, nil, "4" }, {kTechId.Leap, 6, 8}, {kTechId.Umbra, 6, 9},
  
  { kTechId.BioMassFive, 7, 7, nil, "5" },  {kTechId.Vortex, 7, 8}, {kTechId.BoneShield, 7, 9},
  
  { kTechId.BioMassSix, 8, 7, nil, "6" },  {kTechId.Spores, 8, 8},
  
  { kTechId.BioMassSeven, 9, 7, nil, "7" }, {kTechId.Xenocide, 9, 8}, {kTechId.Web, 9, 9},
  
  { kTechId.BioMassEight, 10, 7, nil, "8" },  {kTechId.Stab, 10, 8}, 
  
  { kTechId.BioMassNine, 11, 7, nil, "9" }, {kTechId.Contamination, 11, 8}, {kTechId.Stomp, 11, 9}, 

}

kAlienLines = 
{
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Crag),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Shift),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Shade),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Whip),

    GetLinePositionForTechMap(kAlienTechMap, kTechId.Crag, kTechId.UpgradeOnos),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shift, kTechId.UpgradeLerk),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shade, kTechId.UpgradeFade),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Whip, kTechId.UpgradeSkulk),


    GetLinePositionForTechMap(kAlienTechMap, kTechId.Harvester, kTechId.Hive),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.UpgradeGorge),
    { 7, 1.5, 7, 2.5 },
    { 4, 2.5, 10, 2.5},
    { 4, 2.5, 4, 3},{ 7, 2.5, 7, 3},{ 10, 2.5, 10, 3},
    GetLinePositionForTechMap(kAlienTechMap, kTechId.CragHive, kTechId.Shell),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShadeHive, kTechId.Veil),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShiftHive, kTechId.Spur),
    
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Carapace),GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Regeneration),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Phantom),GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Aura),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Celerity),GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Adrenaline),

}





