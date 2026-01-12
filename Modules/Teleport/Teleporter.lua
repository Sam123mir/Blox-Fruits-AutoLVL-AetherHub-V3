--[[
    AETHER HUB - Teleporter Module
    Core teleportation functions
]]

local Teleporter = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Services.lua"))()

-- Teleport to a CFrame position
function Teleporter:TeleportTo(targetCFrame)
    local hrp = Services:GetHumanoidRootPart()
    if hrp then
        hrp.CFrame = targetCFrame
        return true
    end
    return false
end

-- Teleport to a Vector3 position
function Teleporter:TeleportToPosition(position)
    return self:TeleportTo(CFrame.new(position))
end

-- Smooth teleport using tweening
function Teleporter:TweenTo(targetCFrame, duration)
    duration = duration or 1
    local hrp = Services:GetHumanoidRootPart()
    if not hrp then return false end
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = Services.TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    return true
end

-- Teleport to an instance
function Teleporter:TeleportToInstance(instance)
    if instance and instance:IsA("BasePart") then
        return self:TeleportTo(instance.CFrame)
    elseif instance and instance:FindFirstChild("HumanoidRootPart") then
        return self:TeleportTo(instance.HumanoidRootPart.CFrame)
    elseif instance and instance:FindFirstChild("Handle") then
        return self:TeleportTo(instance.Handle.CFrame)
    end
    return false
end

-- Teleport behind a target
function Teleporter:TeleportBehind(targetHRP)
    if targetHRP then
        local behindPos = targetHRP.CFrame * CFrame.new(0, 0, 3)
        return self:TeleportTo(behindPos)
    end
    return false
end

-- Get distance to a position
function Teleporter:GetDistanceTo(position)
    local hrp = Services:GetHumanoidRootPart()
    if hrp then
        return (hrp.Position - position).Magnitude
    end
    return math.huge
end

return Teleporter
