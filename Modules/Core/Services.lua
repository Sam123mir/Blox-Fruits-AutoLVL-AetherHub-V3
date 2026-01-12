--[[
    AETHER HUB - Services Module
    Centralizes all Roblox service references
    This module is standalone - no dependencies
]]

local Services = {}

-- Core Services
Services.Players = game:GetService("Players")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Workspace = game:GetService("Workspace")
Services.TweenService = game:GetService("TweenService")
Services.UserInputService = game:GetService("UserInputService")
Services.RunService = game:GetService("RunService")

-- Player References
Services.LocalPlayer = Services.Players.LocalPlayer

-- Helper Functions
function Services:GetCharacter()
    return self.LocalPlayer.Character or self.LocalPlayer.CharacterAdded:Wait()
end

function Services:GetHumanoidRootPart()
    local char = self:GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Services:GetHumanoid()
    local char = self:GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Remote References (with error handling)
function Services:GetRemotes()
    local remotes = self.ReplicatedStorage:FindFirstChild("Remotes")
    return remotes
end

function Services:GetCommF()
    local remotes = self:GetRemotes()
    return remotes and remotes:FindFirstChild("CommF_")
end

return Services
