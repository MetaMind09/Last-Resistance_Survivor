local kOnFlamesIcon1 = PrecacheAsset("ui/flame_1.dds")
local kOnFlamesIcon2 = PrecacheAsset("ui/flame_2.dds")
local kOnFlamesIcon3 = PrecacheAsset("ui/flame_3.dds")


function GUIScoreboard:UpdateTeam(updateTeam)
    
    local teamGUIItem = updateTeam["GUIs"]["Background"]
    local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]
    local teamInfoGUIItem = updateTeam["GUIs"]["TeamInfo"]
    local teamNameText = updateTeam["TeamName"]
    local teamColor = updateTeam["Color"]
    local localPlayerHighlightColor = updateTeam["HighlightColor"]
    local playerList = updateTeam["PlayerList"]
    local teamScores = updateTeam["GetScores"]()

    // Determines if the local player can see secret information
    // for this team.
    local isVisibleTeam = false
    local player = Client.GetLocalPlayer()
    if player then
    
        local teamNum = player:GetTeamNumber()
        // Can see secret information if the player is on the team or is a spectator.
        if teamNum == updateTeam["TeamNumber"] or teamNum == kSpectatorIndex then
            isVisibleTeam = true
        end
        
    end
    
    // How many items per player.
    local numPlayers = table.count(teamScores)
    
    // Update the team name text.
    teamNameGUIItem:SetText(string.format("%s (%d %s)", teamNameText, numPlayers, numPlayers == 1 and Locale.ResolveString("SB_PLAYER") or Locale.ResolveString("SB_PLAYERS")))
    
    // Update team resource display
    local teamResourcesString = ConditionalValue(isVisibleTeam, string.format(Locale.ResolveString("SB_TEAM_RES"), ScoreboardUI_GetTeamResources(updateTeam["TeamNumber"])), "")
    teamInfoGUIItem:SetText(string.format("%s", teamResourcesString))
    
    // Make sure there is enough room for all players on this team GUI.
    teamGUIItem:SetSize(Vector(GetTeamItemWidth(), (GUIScoreboard.kTeamItemHeight) + ((GUIScoreboard.kPlayerItemHeight + GUIScoreboard.kPlayerSpacing) * numPlayers), 0))
    
    // Resize the player list if it doesn't match.
    if table.count(playerList) ~= numPlayers then
        self:ResizePlayerList(playerList, numPlayers, teamGUIItem)
    end
    
    local currentY = GUIScoreboard.kTeamNameFontSize + GUIScoreboard.kTeamInfoFontSize + 10
    local currentPlayerIndex = 1
    local deadString = Locale.ResolveString("STATUS_DEAD")
    
    for index, player in pairs(playerList) do
    
        local playerRecord = teamScores[currentPlayerIndex]
        local playerName = playerRecord.Name
        local clientIndex = playerRecord.ClientIndex
        local score = playerRecord.Score
        local kills = playerRecord.Kills
        local assists = playerRecord.Assists
        local deaths = playerRecord.Deaths
        local isCommander = playerRecord.IsCommander and isVisibleTeam == true
        local isRookie = playerRecord.IsRookie
        local resourcesStr = ConditionalValue(isVisibleTeam, tostring(math.floor(playerRecord.Resources * 10) / 10), "-")
        local ping = playerRecord.Ping
        local pingStr = tostring(ping)
        local currentPosition = Vector(player["Background"]:GetPosition())
        local playerStatus = isVisibleTeam and playerRecord.Status or "-"
        local isSpectator = playerRecord.IsSpectator
        local isDead = isVisibleTeam and playerRecord.Status == deadString
        local isSteamFriend = playerRecord.IsSteamFriend
        local playerSkill = playerRecord.Skill
        local Deaths_in_row = playerRecord.Deaths_in_row
        local Kills_in_row = playerRecord.Kills_in_row

        if isCommander then
            score = "*"
        end
        
        currentPosition.y = currentY
        player["Background"]:SetPosition(currentPosition)
        player["Background"]:SetColor(teamColor)
        
        // Handle local player highlight
        if ScoreboardUI_IsPlayerLocal(playerName) then
            if self.playerHighlightItem:GetParent() ~= player["Background"] then
                if self.playerHighlightItem:GetParent() ~= nil then
                    self.playerHighlightItem:GetParent():RemoveChild(self.playerHighlightItem)
                end
                player["Background"]:AddChild(self.playerHighlightItem)
                self.playerHighlightItem:SetIsVisible(true)
                self.playerHighlightItem:SetColor(localPlayerHighlightColor)
            end
        end
        
        player["onFlames"]:SetColor(Color(1, 1, 1, 1))
        if (Kills_in_row and Kills_in_row >= 10) then
            player["onFlames"]:SetTexture(kOnFlamesIcon3)            
            player["onFlames"]:SetIsVisible(true)
        elseif (Kills_in_row and Kills_in_row >= 6) then
            player["onFlames"]:SetTexture(kOnFlamesIcon2)            
            player["onFlames"]:SetIsVisible(true) 
        elseif (Kills_in_row and Kills_in_row >= 3) then
            player["onFlames"]:SetTexture(kOnFlamesIcon1)            
            player["onFlames"]:SetIsVisible(true)        
        else
            if Deaths_in_row >=4  then
                if numPlayers <=3 then
                    player["onFlames"]:SetTexture(kAlien_CamouflageIcon)  
                    player["onFlames"]:SetIsVisible(true) 
                    player["onFlames"]:SetColor(Color(1, 0, 0, 1))
                else
                    player["onFlames"]:SetTexture(kAlien_CarapaceIcon)  
                    player["onFlames"]:SetIsVisible(true)
                end        
            else
                player["onFlames"]:SetIsVisible(false)
            end
        end
        
        player["Number"]:SetText(index..".")
        player["Name"]:SetText(playerName)
        
        // Needed to determine who to (un)mute when voice icon is clicked.
        player["ClientIndex"] = clientIndex
        
        // Voice icon.
        local playerVoiceColor = GUIScoreboard.kVoiceDefaultColor
        if ChatUI_GetClientMuted(clientIndex) then
            playerVoiceColor = GUIScoreboard.kVoiceMuteColor
        elseif ChatUI_GetIsClientSpeaking(clientIndex) then
            playerVoiceColor = teamColor
        end

        player["Voice"]:SetColor(playerVoiceColor)
        player["Score"]:SetText(tostring(score))
        player["Kills"]:SetText(tostring(kills))
        player["Assists"]:SetText(tostring(assists))
        player["Deaths"]:SetText(tostring(deaths))
        player["Status"]:SetText(playerStatus)
        player["Resources"]:SetText(resourcesStr)
        player["Ping"]:SetText(pingStr)
        
        if isCommander then
        
            player["Score"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Kills"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Assists"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Deaths"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Status"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Resources"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Ping"]:SetColor(GUIScoreboard.kCommanderFontColor)    
            player["Name"]:SetColor(GUIScoreboard.kCommanderFontColor)

        elseif isDead and isVisibleTeam then
        
            player["Name"]:SetColor(kDeadColor)
            player["Status"]:SetColor(kDeadColor)
            
        elseif isSteamFriend then
    
            player["Name"]:SetColor(kSteamFriendColor)
            player["Status"]:SetColor(kSteamFriendColor)
            
        elseif playerRecord.IsRookie then
        
            player["Name"]:SetColor(kNewPlayerColorFloat)
            player["Status"]:SetColor(GUIScoreboard.kWhiteColor)
        
        else
        
            player["Score"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Kills"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Assists"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Deaths"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Status"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Resources"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Ping"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Name"]:SetColor(GUIScoreboard.kWhiteColor)

        end  

        if ping < GUIScoreboard.kLowPingThreshold then
            player["Ping"]:SetColor(GUIScoreboard.kLowPingColor)
        elseif ping < GUIScoreboard.kMedPingThreshold then
            player["Ping"]:SetColor(GUIScoreboard.kMedPingColor)
        elseif ping < GUIScoreboard.kHighPingThreshold then
            player["Ping"]:SetColor(GUIScoreboard.kHighPingColor)
        else
            player["Ping"]:SetColor(GUIScoreboard.kInsanePingColor)
        end
        currentY = currentY + GUIScoreboard.kPlayerItemHeight + GUIScoreboard.kPlayerSpacing
        currentPlayerIndex = currentPlayerIndex + 1

        
        local offset = kPlayerItemLeftMargin + kPlayerNumberWidth + kPlayerVoiceChatIconSize
        
        if player["SkillBar"] then
        
            local skillFraction = playerSkill / kMaxPlayerSkill
        
            player["SkillBar"]:SetSize(Vector(kSkillBarSize.x * skillFraction, kSkillBarSize.y, 0))
            player["SkillBar"]:SetPosition(Vector(kPlayerItemLeftMargin + kPlayerNumberWidth + kPlayerVoiceChatIconSize, -kSkillBarSize.y * 0.5, 0))
            offset = offset + kSkillBarSize.x + kSkillBarPadding     

            local skillColor = Color(0,0,0,0)
            if skillFraction >= 0.5 then
                skillColor = LerpColor(kYellow, kRed, (skillFraction - 0.5) * 2)
            elseif skillFraction < 0.5 then
                skillColor = LerpColor(kGreen, kYellow, skillFraction * 2)
            end    

            player["SkillBar"]:SetColor(skillColor)  
            
        end
        
        // update badges info
        offset = offset + SetPlayerItemBadges( player, Badges_GetBadgeTextures(clientIndex, "scoreboard") )
        
        player["Name"]:SetPosition( Vector(
            offset,
            0,
            0 ))
        
    end

end


function GUIScoreboard:CreatePlayerItem()
    
    // Reuse an existing player item if there is one.
    if table.count(self.reusePlayerItems) > 0 then
        local returnPlayerItem = self.reusePlayerItems[1]
        table.remove(self.reusePlayerItems, 1)
        return returnPlayerItem
    end
    
    // Create background.
    local playerItem = GUIManager:CreateGraphicItem()
    playerItem:SetSize(Vector(GetTeamItemWidth() - (GUIScoreboard.kPlayerItemWidthBuffer * 2), GUIScoreboard.kPlayerItemHeight, 0))
    playerItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerItem:SetPosition(Vector(GUIScoreboard.kPlayerItemWidthBuffer, GUIScoreboard.kPlayerItemHeight / 2, 0))
    playerItem:SetColor(Color(1, 1, 1, 1))
    playerItem:SetTexture("ui/hud_elements.dds")
    playerItem:SetTextureCoordinates(0, 0, 0.558, 0.16)

    local playerItemChildX = kPlayerItemLeftMargin

    // Player number item
    local playerNumber = GUIManager:CreateTextItem()
    playerNumber:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    playerNumber:SetAnchor(GUIItem.Left, GUIItem.Center)
    playerNumber:SetTextAlignmentX(GUIItem.Align_Min)
    playerNumber:SetTextAlignmentY(GUIItem.Align_Center)
    playerNumber:SetPosition(Vector(playerItemChildX, 0, 0))
    playerItemChildX = playerItemChildX + kPlayerNumberWidth
    playerNumber:SetColor(Color(0.5, 0.5, 0.5, 1))
    playerItem:AddChild(playerNumber)

    // Player voice icon item.
    local playerVoiceIcon = GUIManager:CreateGraphicItem()
    playerVoiceIcon:SetSize(Vector(kPlayerVoiceChatIconSize, kPlayerVoiceChatIconSize, 0))
    playerVoiceIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    playerVoiceIcon:SetPosition(Vector(
                playerItemChildX,
                -kPlayerVoiceChatIconSize/2,
                0))
    playerItemChildX = playerItemChildX + kPlayerVoiceChatIconSize
    playerVoiceIcon:SetTexture("ui/speaker.dds")
    playerItem:AddChild(playerVoiceIcon)
    
    local playerSkillBar
    /*
    if GetGameInfoEntity():GetIsGatherReady() then
    
        playerSkillBar = GUIManager:CreateGraphicItem()
        playerSkillBar:SetAnchor(GUIItem.Left, GUIItem.Center)
        playerItem:AddChild(playerSkillBar)
        
        playerItemChildX = playerItemChildX + kSkillBarSize.x + kSkillBarPadding
    
    end
    */
    
    //----------------------------------------
    //  Badge icons
    //----------------------------------------
    local maxBadges = Badges_GetMaxBadges()
    local badgeItems = {}
    
    // Player badges
    for i = 1,maxBadges do

        local playerBadge = GUIManager:CreateGraphicItem()
        playerBadge:SetSize(Vector(kPlayerBadgeIconSize, kPlayerBadgeIconSize, 0))
        playerBadge:SetAnchor(GUIItem.Left, GUIItem.Center)
        playerBadge:SetPosition(Vector(playerItemChildX, -kPlayerBadgeIconSize/2, 0))
        playerItemChildX = playerItemChildX + kPlayerBadgeIconSize + kPlayerBadgeRightPadding
        playerBadge:SetIsVisible(false)
        playerItem:AddChild(playerBadge)
        table.insert( badgeItems, playerBadge )

    end

    // Player name text item.
    local playerNameItem = GUIManager:CreateTextItem()
    playerNameItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    playerNameItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    playerNameItem:SetTextAlignmentX(GUIItem.Align_Min)
    playerNameItem:SetTextAlignmentY(GUIItem.Align_Center)
    playerNameItem:SetPosition(Vector(
                playerItemChildX,
                0, 0))
    playerNameItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(playerNameItem)

    local currentColumnX = Client.GetScreenWidth() / 6
    
    local onFlames = GUIManager:CreateGraphicItem()
    onFlames:SetAnchor(GUIItem.Left, GUIItem.Top)
    onFlames:SetTextAlignmentX(GUIItem.Align_Min)
    onFlames:SetTextAlignmentY(GUIItem.Align_Min)
    onFlames:SetPosition(Vector(currentColumnX-21, 4, 0))
    onFlames:SetSize(Vector(20, 20, 0))
    onFlames:SetLayer(kGUILayerScoreboard)
    onFlames:SetTexture(kConnectionProblemsIcon)
    onFlames:SetColor(Color(1, 1, 1, 1))
    onFlames:SetIsVisible(false)
    playerItem:AddChild(onFlames)

    // Status text item.
    local statusItem = GUIManager:CreateTextItem()
    statusItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    statusItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    statusItem:SetTextAlignmentX(GUIItem.Align_Min)
    statusItem:SetTextAlignmentY(GUIItem.Align_Center)
    statusItem:SetPosition(Vector(currentColumnX + 60, 0, 0))
    statusItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(statusItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX * 2 + 35
    
    // Score text item.
    local scoreItem = GUIManager:CreateTextItem()
    scoreItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    scoreItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    scoreItem:SetTextAlignmentX(GUIItem.Align_Min)
    scoreItem:SetTextAlignmentY(GUIItem.Align_Center)
    scoreItem:SetPosition(Vector(currentColumnX + 30, 0, 0))
    scoreItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(scoreItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX + 30
    
    // Kill text item.
    local killsItem = GUIManager:CreateTextItem()
    killsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    killsItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    killsItem:SetTextAlignmentX(GUIItem.Align_Min)
    killsItem:SetTextAlignmentY(GUIItem.Align_Center)
    killsItem:SetPosition(Vector(currentColumnX, 0, 0))
    killsItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(killsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // assists text item.
    local assistsItem = GUIManager:CreateTextItem()
    assistsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    assistsItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    assistsItem:SetTextAlignmentX(GUIItem.Align_Min)
    assistsItem:SetTextAlignmentY(GUIItem.Align_Center)
    assistsItem:SetPosition(Vector(currentColumnX, 0, 0))
    assistsItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(assistsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Deaths text item.
    local deathsItem = GUIManager:CreateTextItem()
    deathsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    deathsItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    deathsItem:SetTextAlignmentX(GUIItem.Align_Min)
    deathsItem:SetTextAlignmentY(GUIItem.Align_Center)
    deathsItem:SetPosition(Vector(currentColumnX, 0, 0))
    deathsItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(deathsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Resources text item.
    local resItem = GUIManager:CreateTextItem()
    resItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    resItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    resItem:SetTextAlignmentX(GUIItem.Align_Min)
    resItem:SetTextAlignmentY(GUIItem.Align_Center)
    resItem:SetPosition(Vector(currentColumnX, 0, 0))
    resItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(resItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Ping text item.
    local pingItem = GUIManager:CreateTextItem()
    pingItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    pingItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    pingItem:SetTextAlignmentX(GUIItem.Align_Min)
    pingItem:SetTextAlignmentY(GUIItem.Align_Center)
    pingItem:SetPosition(Vector(currentColumnX, 0, 0))
    pingItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(pingItem)
    
    return { Background = playerItem, onFlames = onFlames, Number = playerNumber, Name = playerNameItem,
        Voice = playerVoiceIcon, Status = statusItem, Score = scoreItem, Kills = killsItem,
        Assists = assistsItem, Deaths = deathsItem, Resources = resItem, Ping = pingItem,
        BadgeItems = badgeItems, SkillBar = playerSkillBar
    }
    
end