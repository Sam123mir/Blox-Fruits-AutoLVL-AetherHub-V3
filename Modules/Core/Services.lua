--[[
    AETHER HUB - Services Module (v3.1 - Simplified)
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

-- Get Character
function Services:GetCharacter()
    return self.LocalPlayer.Character or self.LocalPlayer.CharacterAdded:Wait()
end

-- Get HumanoidRootPart
function Services:GetHumanoidRootPart()
    local char = self:GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Get Humanoid
function Services:GetHumanoid()
    local char = self:GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

-- Get Remotes
function Services:GetRemotes()
    return self.ReplicatedStorage:FindFirstChild("Remotes")
end

-- Get CommF_
function Services:GetCommF()
    local remotes = self:GetRemotes()
    if remotes then
        return remotes:FindFirstChild("CommF_")
    end
    return nil
end

-- Invoke CommF safely
function Services:InvokeCommF(...)
    local commF = self:GetCommF()
    if not commF then
        return false, "CommF_ not found"
    end
    
    local success, result = pcall(function()
        return commF:InvokeServer(...)
    end)
    
    return success, result
end

return Services