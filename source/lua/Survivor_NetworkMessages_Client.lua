//
// lua\Survivor_NetworkMessages_Client.lua
//
//    Created by:   Lassi lassi@heisl.org
//

//TODO: find a way to hook into localization to enable multi language support

local function OnCommandJoinError(message)
    ChatUI_AddSystemMessage( "In Survivor all players start as Marines. Please join the Marine team." )
end

//TODO: Error: The Message JoinError was already hooked
//can't find a way to print the custom message right now
Client.HookNetworkMessage("JoinError", OnCommandJoinError)