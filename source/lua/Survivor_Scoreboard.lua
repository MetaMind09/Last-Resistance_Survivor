function Scoreboard_OnResetGame()

    // For each player, clear game data (on reset)
    for i = 1, table.maxn(playerData) do
    
        local playerRecord = playerData[i]
        
        playerRecord.EntityId = 0
        playerRecord.EntityTeamNumber = 0
        playerRecord.Score = 0
        playerRecord.Kills = 0
        playerRecord.Deaths = 0
        playerRecord.IsCommander = false
        playerRecord.IsRookie = false
        playerRecord.Status = ""
        playerRecord.IsSpectator = false
        playerRecord.Deaths_in_row = 0
        playerRecord.Kills_in_row = 0

        
    end 

end

function Scoreboard_SetPlayerData(clientIndex, entityId, playerName, teamNumber, score, kills, deaths, resources, isCommander, isRookie, status, isSpectator, assists, steamId, playerSkill, Deaths_in_row, Kills_in_row )


    // Lookup record for player and update it
    for i = 1, table.maxn(playerData) do
    
        local playerRecord = playerData[i]
        
        if playerRecord.ClientIndex == clientIndex then

            // Update entry
            playerRecord.EntityId = entityId
            playerRecord.Name = playerName
            playerRecord.EntityTeamNumber = teamNumber
            playerRecord.Score = score
            playerRecord.Kills = kills
            playerRecord.Assists = assists
            playerRecord.Deaths = deaths
            playerRecord.IsCommander = isCommander
            playerRecord.IsRookie = isRookie
            playerRecord.Resources = resources
            playerRecord.Status = status
            playerRecord.IsSpectator = isSpectator
            playerRecord.Skill = playerSkill
            playerRecord.Deaths_in_row = Deaths_in_row
            playerRecord.Kills_in_row = Kills_in_row

            Scoreboard_Sort()
            
            return
            
        end
        
    end
        
    // Otherwise insert a new record
    local playerRecord = {}

    playerRecord.ClientIndex = clientIndex
    playerRecord.IsSteamFriend = Client.GetIsSteamFriend(steamId)
    playerRecord.EntityId = entityId
    playerRecord.Name = playerName
    playerRecord.EntityTeamNumber = teamNumber
    playerRecord.Score = score
    playerRecord.Kills = kills
    playerRecord.Assists = assists
    playerRecord.Deaths = deaths
    playerRecord.IsCommander = isCommander
    playerRecord.IsRookie = isRookie
    playerRecord.Ping = 0
    playerRecord.Status = status
    playerRecord.IsSpectator = isSpectator
    playerRecord.Skill = playerSkill
    playerRecord.Deaths_in_row = Deaths_in_row
    playerRecord.Kills_in_row = Kills_in_row

    table.insert(playerData, playerRecord )
    
    Scoreboard_Sort()
    
end

function Scoreboard_SetPlayerData(clientIndex, entityId, playerName, teamNumber, score, kills, deaths, resources, isCommander, isRookie, status, isSpectator, assists, steamId, playerSkill )
  nil
end