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

-- Load Modules
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Services.lua"))()
local Variables = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Variables.lua"))()
local FruitFinder = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Fruit/FruitFinder.lua"))()
local FruitStorage = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Fruit/FruitStorage.lua"))()
local FruitTeleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Teleport/FruitTeleport.lua"))()
local AutoFarm = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Combat/AutoFarm.lua"))()

-- Create Window
local Window = Starlight:CreateWindow({
    Name = "AETHER HUB",
    Subtitle = "Blox Fruits v2.0.0",
    Icon = 0,
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "AETHER HUB",
        Subtitle = "Loading modules...",
    },
    FileSettings = {
        ConfigFolder = "AetherHub"
    }
})

-- ============================================
-- TAB SECTION: Profile (invisible section)
-- ============================================
local ProfileSection = Window:CreateTabSection("Profile", false)

local HomeTab = ProfileSection:CreateTab({
    Name = "Home",
    Icon = NebulaIcons:GetIcon("home", "Lucide"),
    Columns = 2
}, "HomeTab")

-- Create Groupbox for welcome info
local WelcomeBox = HomeTab:CreateGroupbox({
    Name = "Welcome"
})

WelcomeBox:CreateParagraph({
    Title = "AETHER HUB",
    Content = "Welcome to AETHER HUB v2.0.0\nThe ultimate Blox Fruits script."
})

WelcomeBox:CreateParagraph({
    Title = "Player Info",
    Content = "World: " .. (Variables.World or "Unknown") .. "\nLevel: " .. AutoFarm:GetLevel()
})

-- ============================================
-- TAB SECTION: Main Features
-- ============================================
local MainSection = Window:CreateTabSection("Main")

-- TAB: Combat
local CombatTab = MainSection:CreateTab({
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
        Variables.AutoFarm = value
        if value then
            AutoFarm:Start()
        else
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
        Variables.FarmDistance = value
    end
}, "FarmDistanceSlider")

-- TAB: Fruit
local FruitTab = MainSection:CreateTab({
    Name = "Fruit",
    Icon = NebulaIcons:GetIcon("cherry", "Lucide"),
    Columns = 2
}, "FruitTab")

local FruitBox = FruitTab:CreateGroupbox({
    Name = "Devil Fruit"
})

FruitBox:CreateToggle({
    Name = "Auto TP to Fruit",
    CurrentValue = false,
    Callback = function(value)
        Variables.FruitTeleport = value
        if value then
            FruitTeleport:Start()
        else
            FruitTeleport:Stop()
        end
    end
}, "FruitTPToggle")

FruitBox:CreateToggle({
    Name = "Auto Store Fruit",
    CurrentValue = false,
    Callback = function(value)
        Variables.FruitAutoStore = value
    end
}, "FruitStoreToggle")

FruitBox:CreateButton({
    Name = "Teleport to Closest Fruit",
    Callback = function()
        local fruit = FruitTeleport:TeleportToClosestFruit()
        if fruit then
            Starlight:Notify({
                Title = "Fruit Found",
                Content = "Teleported to: " .. fruit.Name,
                Duration = 3
            })
        else
            Starlight:Notify({
                Title = "No Fruit",
                Content = "No devil fruit found in the map",
                Duration = 3
            })
        end
    end
}, "TPFruitButton")

FruitBox:CreateButton({
    Name = "Store Current Fruit",
    Callback = function()
        local success, result = FruitStorage:StoreFruit()
        if success then
            Starlight:Notify({
                Title = "Success",
                Content = "Fruit stored in inventory",
                Duration = 3
            })
        else
            Starlight:Notify({
                Title = "Error",
                Content = "Failed to store fruit",
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
    Name = "Teleport"
})

TPBox:CreateParagraph({
    Title = "Coming Soon",
    Content = "Island teleport features will be added in the next update."
})

-- ============================================
-- TAB SECTION: Settings
-- ============================================
local SettingsSection = Window:CreateTabSection("Settings")

local SettingsTab = SettingsSection:CreateTab({
    Name = "Settings",
    Icon = NebulaIcons:GetIcon("settings", "Lucide"),
    Columns = 2
}, "SettingsTab")

SettingsTab:BuildConfigSection()
SettingsTab:BuildThemeSection()

-- ============================================
-- Initialization Complete
-- ============================================
Starlight:Notify({
    Title = "AETHER HUB",
    Content = "Script loaded successfully!",
    Duration = 5
})

-- Set callback for fruit found notification
FruitTeleport:SetOnFruitFound(function(name, distance)
    Starlight:Notify({
        Title = "Fruit Detected",
        Content = name .. " found at " .. math.floor(distance) .. "m",
        Duration = 3
    })
end)

print("AETHER HUB v2.0.0 loaded successfully!")
