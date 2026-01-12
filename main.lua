--[[
    ================================================================
         █████╗ ███████╗████████╗██╗  ██╗███████╗██████╗ 
        ██╔══██╗██╔════╝╚══██╔══╝██║  ██║██╔════╝██╔══██╗
        ███████║█████╗     ██║   ███████║█████╗  ██████╔╝
        ██╔══██║██╔══╝     ██║   ██╔══██║██╔══╝  ██╔══██╗
        ██║  ██║███████╗   ██║   ██║  ██║███████╗██║  ██║
        ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                    AETHER HUB - Blox Fruits
                         Version 2.0.0
    ================================================================
]]

-- Boot Starlight UI
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

-- Get player info safely
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getPlayerLevel()
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Level") then
            return tostring(data.Level.Value)
        end
    end)
    return "0"
end

local function getPlayerWorld()
    if game.PlaceId == 2753915549 then return "Sea 1"
    elseif game.PlaceId == 4442272183 then return "Sea 2"
    elseif game.PlaceId == 7449423635 then return "Sea 3"
    else return "Unknown"
    end
end

-- Variables
local Settings = {
    AutoFarm = false,
    FarmDistance = 200,
    FruitTeleport = false,
    FruitAutoStore = false
}

-- Create Window with Green Theme
local Window = Starlight:CreateWindow({
    Name = "AETHER HUB",
    Subtitle = "Blox Fruits v2.0.0",
    Icon = 0,
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "AETHER HUB",
        Subtitle = "Initializing...",
    },
    FileSettings = {
        ConfigFolder = "AetherHub"
    }
})

-- ============================================
-- TAB SECTION: Main
-- ============================================
local MainSection = Window:CreateTabSection("Main", false)

local HomeTab = MainSection:CreateTab({
    Name = "Home",
    Icon = NebulaIcons:GetIcon("home", "Lucide"),
    Columns = 1
}, "HomeTab")

local InfoBox = HomeTab:CreateGroupbox({
    Name = "Welcome to AETHER HUB"
})

InfoBox:CreateLabel("Version 2.0.0 | Blox Fruits")
InfoBox:CreateLabel("World: " .. getPlayerWorld())
InfoBox:CreateLabel("Made with Starlight UI")

-- ============================================
-- TAB SECTION: Features
-- ============================================
local FeaturesSection = Window:CreateTabSection("Features")

-- Combat Tab
local CombatTab = FeaturesSection:CreateTab({
    Name = "Combat",
    Icon = NebulaIcons:GetIcon("swords", "Lucide"),
    Columns = 1
}, "CombatTab")

local FarmBox = CombatTab:CreateGroupbox({
    Name = "Auto Farm"
})

FarmBox:CreateToggle({
    Name = "Auto Farm Level",
    CurrentValue = false,
    Callback = function(value)
        Settings.AutoFarm = value
        print("Auto Farm: " .. tostring(value))
    end
}, "AutoFarmToggle")

FarmBox:CreateSlider({
    Name = "Farm Distance",
    Range = {50, 500},
    CurrentValue = 200,
    Increment = 10,
    Callback = function(value)
        Settings.FarmDistance = value
    end
}, "FarmDistanceSlider")

-- Fruit Tab
local FruitTab = FeaturesSection:CreateTab({
    Name = "Fruit",
    Icon = NebulaIcons:GetIcon("cherry", "Lucide"),
    Columns = 1
}, "FruitTab")

local FruitBox = FruitTab:CreateGroupbox({
    Name = "Devil Fruit"
})

FruitBox:CreateToggle({
    Name = "Auto TP to Fruit",
    CurrentValue = false,
    Callback = function(value)
        Settings.FruitTeleport = value
        print("Fruit TP: " .. tostring(value))
    end
}, "FruitTPToggle")

FruitBox:CreateToggle({
    Name = "Auto Store Fruit",
    CurrentValue = false,
    Callback = function(value)
        Settings.FruitAutoStore = value
    end
}, "FruitStoreToggle")

FruitBox:CreateButton({
    Name = "TP to Closest Fruit",
    Callback = function()
        Starlight:Notify({
            Title = "Fruit TP",
            Content = "Searching for fruits...",
            Duration = 3
        })
    end
}, "TPFruitBtn")

FruitBox:CreateButton({
    Name = "Store Current Fruit",
    Callback = function()
        Starlight:Notify({
            Title = "Store Fruit",
            Content = "Attempting to store...",
            Duration = 3
        })
    end
}, "StoreFruitBtn")

-- ============================================
-- TAB SECTION: Teleport
-- ============================================
local TeleportSection = Window:CreateTabSection("Teleport")

local TeleportTab = TeleportSection:CreateTab({
    Name = "Islands",
    Icon = NebulaIcons:GetIcon("map-pin", "Lucide"),
    Columns = 1
}, "TeleportTab")

local TPBox = TeleportTab:CreateGroupbox({
    Name = "World Teleport"
})

TPBox:CreateLabel("Coming Soon!")

-- ============================================
-- TAB SECTION: Settings
-- ============================================
local SettingsSection = Window:CreateTabSection("Settings")

local SettingsTab = SettingsSection:CreateTab({
    Name = "Config",
    Icon = NebulaIcons:GetIcon("settings", "Lucide"),
    Columns = 1
}, "SettingsTab")

SettingsTab:BuildConfigSection()
SettingsTab:BuildThemeSection()

-- ============================================
-- Complete
-- ============================================
Starlight:Notify({
    Title = "AETHER HUB",
    Content = "Loaded successfully!",
    Duration = 5
})

print("AETHER HUB v2.0.0 loaded!")
