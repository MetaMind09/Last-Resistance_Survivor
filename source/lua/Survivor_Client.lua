//
// lua\Survivor_Client.lua
//
//    Created by:   Lassi lassi@heisl.org
//

//load the class hooking utilities by fsfod
Script.Load("lua/PreLoadMod.lua")
Script.Load("lua/PathUtil.lua")
Script.Load("lua/ClassHooker.lua")
Script.Load("lua/LoadTracker.lua")

// RandomizeAliensClient.lua
Script.Load("lua/Client.lua")
Print "Client VM"

//load the shared script
Script.Load("lua/Survivor_Shared.lua")
Script.Load("lua/Survivor_NetworkMessages_Client.lua")
Script.Load("lua/Survivor_PowerPointLightHandler.lua")

//load Language(s)
Script.Load("lua/Survivor_Locale.lua")
//just for reference: how to load option settings in case
//someone feels the need to implement more langs:
//local locale = Client.GetOptionString( "locale", "enUS" )
Script.Load("gamestrings/Survivor_enUS.lua")

//load UI extension
Script.Load("lua/Survivor_GUIMarineHud.lua")
