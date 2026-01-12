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

local REPO_BASE = "https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/"

-- Safe module loader
local function loadModule(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(REPO_BASE .. path))()
    end)
    if success then
        return result
    else
        warn("[AETHER HUB] Failed to load: " .. path)
        return nil
    end
end

print("[AETHER HUB] Loading modules...")

-- Load Core Modules
local Services = loadModule("Modules/Core/Services.lua")
local Variables = loadModule("Modules/Core/Variables.lua")

-- Load Feature Modules
local FruitFinder = loadModule("Modules/Fruit/FruitFinder.lua")
local FruitStorage = loadModule("Modules/Fruit/FruitStorage.lua")
local Teleporter = loadModule("Modules/Teleport/Teleporter.lua")
local AutoFarm = loadModule("Modules/Combat/AutoFarm.lua")

-- Initialize modules with dependencies
if FruitFinder and Services then FruitFinder:Init(Services) end
if FruitStorage and Services then FruitStorage:Init(Services) end
if Teleporter and Services then Teleporter:Init(Services) end
if AutoFarm and Services and Variables and Teleporter then 
    AutoFarm:Init(Services, Variables, Teleporter) 
end

print("[AETHER HUB] Modules loaded!")

-- Boot Starlight UI
print("[AETHER HUB] Loading Starlight UI...")
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

-- Create Window
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
-- TAB SECTION: Main (invisible title)
-- ============================================
local MainSection = Window:CreateTabSection("", false)

local HomeTab = MainSection:CreateTab({
    Name = "Home",
    Icon = NebulaIcons:GetIcon("home", "Lucide"),
    Columns = 1
}, "HomeTab")

local InfoBox = HomeTab:CreateGroupbox({
    Name = "Welcome"
})

InfoBox:CreateLabel("AETHER HUB v2.0.0")
InfoBox:CreateLabel("World: " .. (Variables and Variables.World or "Unknown"))
InfoBox:CreateLabel("Level: " .. (AutoFarm and tostring(AutoFarm:GetLevel()) or "0"))

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
        if Variables then Variables.AutoFarm = value end
        if value and AutoFarm then
            AutoFarm:Start()
        elseif AutoFarm then
            AutoFarm:Stop()
        end
    end
}, "AutoFarmToggle")

FarmBox:CreateSlider({
    Name = "Farm Distance",
    Range = {50, 500},
    CurrentValue = 200,
    Increment = 10,
    Callback = function(value)
        if Variables then Variables.FarmDistance = value end
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
        if Variables then Variables.FruitTeleport = value end
    end
}, "FruitTPToggle")

FruitBox:CreateToggle({
    Name = "Auto Store Fruit",
    CurrentValue = false,
    Callback = function(value)
        if Variables then Variables.FruitAutoStore = value end
    end
}, "FruitStoreToggle")

FruitBox:CreateButton({
    Name = "TP to Closest Fruit",
    Callback = function()
        if FruitFinder and Teleporter then
            local fruit = FruitFinder:GetClosestFruit()
            if fruit then
                Teleporter:TeleportToInstance(fruit.Instance)
                Starlight:Notify({
                    Title = "Fruit Found!",
                    Content = "Teleported to: " .. fruit.Name,
                    Duration = 3
                })
            else
                Starlight:Notify({
                    Title = "No Fruit",
                    Content = "No fruit found in map",
                    Duration = 3
                })
            end
        end
    end
}, "TPFruitBtn")

FruitBox:CreateButton({
    Name = "Store Fruit",
    Callback = function()
        if FruitStorage then
            local success = FruitStorage:StoreFruit()
            Starlight:Notify({
                Title = success and "Success" or "Error",
                Content = success and "Fruit stored!" or "Failed to store",
                Duration = 3
            })
        end
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

print("[AETHER HUB] v2.0.0 loaded successfully!")
