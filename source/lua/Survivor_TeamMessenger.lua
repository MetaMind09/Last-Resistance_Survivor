//
// lua\Survivor_TeamMessenger.lua
//
//    Created by:   Lassi lassi@heisl.org
//

kSurvivorTeamMessageTypes = enum({ 'SurvivalStarted', 'PlayerMutated' })

local kSurvivorTeamMessages = { }

// This function will generate the string to display based on a location Id.
local playerStringGen = function(playerId, messageString) return string.format(Locale.ResolveString(messageString), Shared.GetEntity(playerId):GetName()) end

kSurvivorTeamMessages[kSurvivorTeamMessageTypes.SurvivalStarted] = { text = { [kMarineTeamType] = "MARINE_TEAM_SURVIVAL_STARTED", [kAlienTeamType] = "ALIEN_TEAM_SURVIVAL_STARTED" } }

kSurvivorTeamMessages[kSurvivorTeamMessageTypes.PlayerMutated] = { text = { [kMarineTeamType] = function(data) return playerStringGen(data, "PLAYER_MUTATED") end, [kAlienTeamType] = function(data) return playerStringGen(data, "PLAYER_MUTATED") end } }

// Silly name but it fits the convention.
local kSurvivorTeamMessageMessage =
{
    type = "enum kSurvivorTeamMessageTypes",
    data = "integer"
}

Shared.RegisterNetworkMessage("SurvivorTeamMessage", kSurvivorTeamMessageMessage)

if Server then

    function SendSurvivorTeamMessage(team, messageType, optionalData)
    
        local function SendToPlayer(player)
            Server.SendNetworkMessage(player, "SurvivorTeamMessage", { type = messageType, data = optionalData or 0 }, true)
        end
        
        team:ForEachPlayer(SendToPlayer)
        
    end
    
end

if Client then

    local function SetTeamMessage(messageType, messageData)
    
        local player = Client.GetLocalPlayer()
        if player and HasMixin(player, "TeamMessage") then
        
            if Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full then
        
                local displayText = kSurvivorTeamMessages[messageType].text[player:GetTeamType()]
                
                if displayText then
                
                    if type(displayText) == "function" then
                        displayText = displayText(messageData)
                    else
                        displayText = Locale.ResolveString(displayText)
                    end
                    
                    assert(type(displayText) == "string")
                    player:SetTeamMessage(string.upper(displayText))
                    
                end
            
            end
            
        end
        
    end
    
    function OnCommandSurvivorTeamMessage(message)
        SetTeamMessage(message.type, message.data)
    end
    
    Client.HookNetworkMessage("SurvivorTeamMessage", OnCommandSurvivorTeamMessage)
    
end

