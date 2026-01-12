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

-- Safe require modules with error handling
local function safeLoad(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        return result
    else
        warn("Failed to load module: " .. url)
        return nil
    end
end

-- Load Modules
local Services = safeLoad("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Services.lua")
local Variables = safeLoad("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Variables.lua")
local FruitTeleport = safeLoad("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Teleport/FruitTeleport.lua")
local FruitStorage = safeLoad("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Fruit/FruitStorage.lua")
local AutoFarm = safeLoad("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Combat/AutoFarm.lua")

-- Get player info safely
local function getPlayerLevel()
    local success, level = pcall(function()
        local data = game:GetService("Players").LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Level") then
            return data.Level.Value
        end
        return 0
    end)
    return success and level or 0
end

local function getPlayerWorld()
    if game.PlaceId == 2753915549 then return "Sea 1"
    elseif game.PlaceId == 4442272183 then return "Sea 2"
    elseif game.PlaceId == 7449423635 then return "Sea 3"
    else return "Unknown"
    end
end

-- Create Window
local Window = Starlight:CreateWindow({
    Name = "AETHER HUB",
    Subtitle = "Blox Fruits v2.0.0",
    Icon = 0,
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "AETHER HUB",
        Subtitle = "Loading...",
    },
    FileSettings = {
        ConfigFolder = "AetherHub"
    }
})

-- ============================================
-- TAB SECTION: Home (invisible title)
-- ============================================
local HomeSection = Window:CreateTabSection("", false)

local HomeTab = HomeSection:CreateTab({
    Name = "Home",
    Icon = NebulaIcons:GetIcon("home", "Lucide"),
    Columns = 2
}, "HomeTab")

local InfoBox = HomeTab:CreateGroupbox({
    Name = "Player Info"
})

InfoBox:CreateParagraph({
    Title = "Welcome",
    Content = "AETHER HUB v2.0.0\nThe ultimate Blox Fruits script"
})

InfoBox:CreateParagraph({
    Title = "Status",
    Content = "World: " .. getPlayerWorld() .. "\nLevel: " .. tostring(getPlayerLevel())
})

-- ============================================
-- TAB SECTION: Features
-- ============================================
local FeaturesSection = Window:CreateTabSection("Features")

-- TAB: Combat
local CombatTab = FeaturesSection:CreateTab({
    Name = "Combat",
    Icon = NebulaIcons:GetIcon("swords", "Lucide"),
    Columns = 2
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

-- TAB: Fruit
local FruitTab = FeaturesSection:CreateTab({
    Name = "Devil Fruit",
    Icon = NebulaIcons:GetIcon("cherry", "Lucide"),
    Columns = 2
}, "FruitTab")

local FruitBox = FruitTab:CreateGroupbox({
    Name = "Fruit Features"
})

FruitBox:CreateToggle({
    Name = "Auto TP to Fruit",
    CurrentValue = false,
    Callback = function(value)
        if Variables then Variables.FruitTeleport = value end
        if value and FruitTeleport then
            FruitTeleport:Start()
        elseif FruitTeleport then
            FruitTeleport:Stop()
        end
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
        if FruitTeleport then
            local fruit = FruitTeleport:TeleportToClosestFruit()
            if fruit then
                Starlight:Notify({
                    Title = "Fruit Found",
                    Content = "Teleported to: " .. tostring(fruit.Name),
                    Duration = 3
                })
            else
                Starlight:Notify({
                    Title = "No Fruit",
                    Content = "No devil fruit found",
                    Duration = 3
                })
            end
        end
    end
}, "TPFruitButton")

FruitBox:CreateButton({
    Name = "Store Fruit",
    Callback = function()
        if FruitStorage then
            local success = FruitStorage:StoreFruit()
            Starlight:Notify({
                Title = success and "Success" or "Error",
                Content = success and "Fruit stored" or "Failed to store",
                Duration = 3
            })
        end
    end
}, "StoreFruitButton")

-- ============================================
-- TAB SECTION: Teleport
-- ============================================
local TeleportSection = Window:CreateTabSection("Teleport")

local TeleportTab = TeleportSection:CreateTab({
    Name = "World TP",
    Icon = NebulaIcons:GetIcon("map-pin", "Lucide"),
    Columns = 2
}, "TeleportTab")

local TPBox = TeleportTab:CreateGroupbox({
    Name = "Islands"
})

TPBox:CreateParagraph({
    Title = "Coming Soon",
    Content = "Island TP will be added soon"
})

-- ============================================
-- TAB SECTION: Config
-- ============================================
local ConfigSection = Window:CreateTabSection("Config")

local SettingsTab = ConfigSection:CreateTab({
    Name = "Settings",
    Icon = NebulaIcons:GetIcon("settings", "Lucide"),
    Columns = 2
}, "SettingsTab")

SettingsTab:BuildConfigSection()
SettingsTab:BuildThemeSection()

-- ============================================
-- Done
-- ============================================
Starlight:Notify({
    Title = "AETHER HUB",
    Content = "Loaded successfully!",
    Duration = 5
})

print("AETHER HUB v2.0.0 loaded!")
