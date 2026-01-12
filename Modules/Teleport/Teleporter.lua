--[[
    AETHER HUB - Teleporter Module
    Teleport functions
    Requires: Services (passed via init)
]]

local Teleporter = {}
Teleporter.Services = nil

function Teleporter:Init(services)
    self.Services = services
    return self
end

-- Teleport to CFrame
function Teleporter:TeleportTo(targetCFrame)
    if not self.Services then return false end
    
    local hrp = self.Services:GetHumanoidRootPart()
    if hrp then
        hrp.CFrame = targetCFrame
        return true
    end
    return false
end

-- Teleport to position
function Teleporter:TeleportToPosition(position)
    return self:TeleportTo(CFrame.new(position))
end

-- Teleport to instance
function Teleporter:TeleportToInstance(instance)
    if not instance then return false end
    
    if instance:IsA("BasePart") then
        return self:TeleportTo(instance.CFrame)
    elseif instance:FindFirstChild("HumanoidRootPart") then
        return self:TeleportTo(instance.HumanoidRootPart.CFrame)
    elseif instance:FindFirstChild("Handle") then
        return self:TeleportTo(instance.Handle.CFrame)
    end
    return false
end

-- Teleport behind target
function Teleporter:TeleportBehind(targetHRP)
    if targetHRP then
        local behindPos = targetHRP.CFrame * CFrame.new(0, 0, 3)
        return self:TeleportTo(behindPos)
    end
    return false
end

return Teleporter
