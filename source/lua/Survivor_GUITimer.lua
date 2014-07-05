// lua\Survivor_GUITimer.lua
//
//    Created by:   Lassi lassi@heisl.org
//
//NOTE: this file originated as a copy of FadedGUIRoundTimer.lua from the NS2 Faded Mod
//      by Rio (rio@myrio.de)
//

class 'Survivor_GUITimer' (GUIScript)

Survivor_GUITimer.kGameTimeBackgroundSize = Vector(200, GUIScale(32), 0)
Survivor_GUITimer.kFontName = "fonts/AgencyFB_large.fnt"
Survivor_GUITimer.kGameTimeTextSize = GUIScale(22)

function Survivor_GUITimer:Initialize()
    self.gameTimeBackground = GUIManager:CreateGraphicItem()
    self.gameTimeBackground:SetSize(Survivor_GUITimer.kGameTimeBackgroundSize)
    self.gameTimeBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.gameTimeBackground:SetPosition( Vector(- Survivor_GUITimer.kGameTimeBackgroundSize.x / 2, 5, 0) )
    self.gameTimeBackground:SetIsVisible(false)
    self.gameTimeBackground:SetColor(Color(0,0,0,0.5))
    self.gameTimeBackground:SetLayer(kGUILayerCountDown)
    
    self.gameTime = GUIManager:CreateTextItem()
    self.gameTime:SetFontName(Survivor_GUITimer.kFontName)
    self.gameTime:SetFontSize(Survivor_GUITimer.kGameTimeTextSize)
    self.gameTime:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.gameTime:SetTextAlignmentX(GUIItem.Align_Center)
    self.gameTime:SetTextAlignmentY(GUIItem.Align_Center)
    self.gameTime:SetColor(Color(1, 1, 1, 1))
    self.gameTime:SetText("")
    self.gameTimeBackground:AddChild(self.gameTime)
end    

function Survivor_GUITimer:Uninitialize()
    GUI.DestroyItem(self.gameTime)
    self.gameTime = nil
    GUI.DestroyItem(self.gameTimeBackground)
    self.gameTimeBackground = nil
end

function Survivor_GUITimer:Update(deltaTime)    
    local isVisible = true   
        
    self.gameTimeBackground:SetIsVisible(isVisible)
    self.gameTime:SetIsVisible(isVisible)
    
    local timeLeft = survivalStartTime + kRoundTime - Shared.GetTime()
    local minutes = math.floor(timeLeft/60)
    local seconds = timeLeft - minutes*60
    
    self.gameTime:SetText(string.format("%d:%02d", minutes, seconds))
end  