--[[
    AETHER HUB - Services Module
    Centralizes all Roblox service references
]]

local Services = {}

-- Core Services
Services.Players = game:GetService("Players")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Workspace = game:GetService("Workspace")
Services.Lighting = game:GetService("Lighting")
Services.TweenService = game:GetService("TweenService")
Services.UserInputService = game:GetService("UserInputService")
Services.RunService = game:GetService("RunService")
Services.HttpService = game:GetService("HttpService")
Services.VirtualUser = game:GetService("VirtualUser")

-- Player References
Services.LocalPlayer = Services.Players.LocalPlayer

-- Remote References
Services.Remotes = Services.ReplicatedStorage:WaitForChild("Remotes", 10)
Services.CommF_ = Services.Remotes and Services.Remotes:FindFirstChild("CommF_")

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

return Services
