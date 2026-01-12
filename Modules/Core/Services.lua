--[[
    AETHER HUB - Services Module (v3.2 - Maximum Compatibility)
    Core services wrapper for Blox Fruits
]]

local Services = {}

-- Core Services
Services.Players = game:GetService("Players")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Workspace = game:GetService("Workspace")
Services.TweenService = game:GetService("TweenService")
Services.UserInputService = game:GetService("UserInputService")
Services.RunService = game:GetService("RunService")

-- Player Reference
Services.LocalPlayer = Services.Players.LocalPlayer

-- Get Character (simple version)
function Services:GetCharacter()
    return self.LocalPlayer and self.LocalPlayer.Character
end

-- Get HumanoidRootPart
function Services:GetHumanoidRootPart()
    local char = self:GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Get Humanoid
function Services:GetHumanoid()
    local char = self:GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Get Remotes
function Services:GetRemotes()
    return self.ReplicatedStorage:FindFirstChild("Remotes")
end

-- Get CommF_
function Services:GetCommF()
    local remotes = self:GetRemotes()
    return remotes and remotes:FindFirstChild("CommF_")
end

-- Invoke CommF safely
function Services:InvokeCommF(...)
    local commF = self:GetCommF()
    if not commF then
        return false, "CommF_ not found"
    end
    
    local args = {...}
    local success, result = pcall(function()
        return commF:InvokeServer(unpack(args))
    end)
    
    return success, result
end

return Services