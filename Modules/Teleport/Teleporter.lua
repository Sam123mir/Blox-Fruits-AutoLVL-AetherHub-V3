--[[
    AETHER HUB - Teleporter Module (v3.1 - Simplified)
    Teleportation utilities
]]

local Teleporter = {}

-- Dependencies (will be set via Init)
local Services = nil

-- Initialize
function Teleporter.new(services)
    Services = services
    return Teleporter
end

-- Also support Init pattern
function Teleporter:Init(services)
    Services = services
    return self
end

-- Teleport to CFrame
function Teleporter:TeleportTo(targetCFrame, options)
    if not Services then return false end
    
    local hrp = Services:GetHumanoidRootPart()
    if not hrp then return false end
    
    -- Apply offset if provided
    options = options or {}
    if options.offset then
        targetCFrame = targetCFrame * CFrame.new(options.offset)
    end
    
    hrp.CFrame = targetCFrame
    return true
end

-- Teleport to position
function Teleporter:TeleportToPosition(position, options)
    return self:TeleportTo(CFrame.new(position), options)
end

-- Teleport to instance
function Teleporter:TeleportToInstance(instance, options)
    if not instance then return false end
    
    local targetCFrame = nil
    
    if instance:IsA("BasePart") then
        targetCFrame = instance.CFrame
    elseif instance:IsA("Model") then
        local hrp = instance:FindFirstChild("HumanoidRootPart")
        if hrp then
            targetCFrame = hrp.CFrame
        elseif instance.PrimaryPart then
            targetCFrame = instance.PrimaryPart.CFrame
        end
    elseif instance:IsA("Tool") then
        local handle = instance:FindFirstChild("Handle")
        if handle then
            targetCFrame = handle.CFrame
        end
    end
    
    if targetCFrame then
        return self:TeleportTo(targetCFrame * CFrame.new(0, 3, 0), options)
    end
    
    return false
end

-- Teleport behind target
function Teleporter:TeleportBehind(targetHRP, distance)
    if not targetHRP then return false end
    
    distance = distance or 3
    local behindCFrame = targetHRP.CFrame * CFrame.new(0, 0, distance)
    
    return self:TeleportTo(behindCFrame)
end

return Teleporter