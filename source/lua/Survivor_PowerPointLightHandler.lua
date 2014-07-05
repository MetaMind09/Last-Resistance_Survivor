//
// lua\Survivor_PowerPointLightHandler.lua
//
//    Created by:   Lassi lassi@heisl.org
//

//
// copy of the original NS2 NoPowerLightWorker 
// removed auxillary lights completly
//
local kPowerDownTime = 1
local kOffTime = 15

// set the intensity and color for a light. If the renderlight is ambient, we set the color
// the same in all directions
local function SetLight(renderLight, intensity, color)

    if intensity then
        renderLight:SetIntensity(intensity)
    end
    
    if color then
    
        renderLight:SetColor(color)
        
        if renderLight:GetType() == RenderLight.Type_AmbientVolume then
        
            renderLight:SetDirectionalColor(RenderLight.Direction_Right,    color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Left,     color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Up,       color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Down,     color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Forward,  color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Backward, color)
            
        end
        
    end
    
end

function NoPowerLightWorker:Run()

    PROFILE("NoPowerLightWorker:Run")

    local timeOfChange = self.handler.powerPoint:GetTimeOfLightModeChange()
    local time = Shared.GetTime()
    local timePassed = time - timeOfChange    
    
    local startAuxLightTime = kPowerDownTime + kOffTime
    
    local probeTint
    
    if timePassed < kPowerDownTime then
        local intensity = math.sin(Clamp(timePassed / kPowerDownTime, 0, 1) * math.pi / 2)
        probeTint = Color(intensity, intensity, intensity, 1)
    else
        probeTint = Color(0, 0, 0, 1)
    end

    if self.activeProbes then    
        for probe,_ in pairs(self.handler.probeTable) do
            probe:SetTint( probeTint )
        end
    end

    
    for renderLight,_ in pairs(self.activeLights) do
        
        local randomValue = renderLight.randomValue
       
        local intensity = nil
        local color = nil
        
        if timePassed < kPowerDownTime then
            local scalar = math.sin(Clamp(timePassed / kPowerDownTime, 0, 1) * math.pi / 2)
            scalar = (1 - scalar)
            intensity = renderLight.originalIntensity * (1 - scalar)
        else 
            intensity = 0  
        end
        
        SetLight(renderLight, intensity, color)
        
    end

    // handle the light-cycling groups.
    for _,lightGroup in pairs(self.lightGroups) do
        lightGroup:Run(timePassed)
    end

end