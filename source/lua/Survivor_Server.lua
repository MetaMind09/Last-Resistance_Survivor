//
// lua\Survivor_Server.lua
//
//    Created by:   Lassi lassi@heisl.org
//

//currently there are no server hooks so we don't need to load the framework here
//TODO: use it or remove it

////load the class hooking utilities by fsfod
//BEFORE loading the base NS2 server
//Script.Load("lua/PreLoadMod.lua")
//Script.Load("lua/PathUtil.lua")
//Script.Load("lua/ClassHooker.lua")
//Script.Load("lua/LoadTracker.lua")
//
////load mixin & player hooks
//Script.Load("lua/Survivor_PlayerHooks.lua")

// RandomizeAliensServer.lua
Script.Load("lua/Server.lua")
Print "Server VM"
//load the shared script
Script.Load("lua/Survivor_Shared.lua")

Script.Load("lua/Survivor_Team.lua")
Script.Load("lua/Survivor_AlienTeam.lua")
Script.Load("lua/Survivor_MarineTeam.lua")
Script.Load("lua/Survivor_Skulk_Server.lua")

//mixin overrides
Script.Load("lua/Survivor_PointGiverMixin.lua")
Script.Load("lua/Survivor_ScoringMixin.lua")



local function postServerMsg(player, message)
    local locationId = -1
    
    Server.SendNetworkMessage(player, "Chat", BuildChatMessage(true, "Server", locationId, player:GetTeamNumber(), kNeutralTeamType, message), true)
end

local function OnClientConnect(client)
    local player = client:GetControllingPlayer()
    local welcomeMsg = "Welcome to the Last Resistance(Survivor) - Mod!"
    local createdby = "Created by MetaMind09,[My-G-N] OnkelDagobert and Liriel"
    local gamerulez = "Press ESC for Gamerulez"
    
    welcomeMsg = string.format(welcomeMsg)
    createdby = string.format(createdby)
    gamerulez = string.format(gamerulez)
    
    postServerMsg(player, welcomeMsg)
    postServerMsg(player, createdby)
    postServerMsg(player, gamerulez)
end

Event.Hook("ClientConnect", OnClientConnect)
