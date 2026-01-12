--[[
    ================================================================
         █████╗ ███████╗████████╗██╗  ██╗███████╗██████╗ 
        ██╔══██╗██╔════╝╚══██╔══╝██║  ██║██╔════╝██╔══██╗
        ███████║█████╗     ██║   ███████║█████╗  ██████╔╝
        ██╔══██║██╔══╝     ██║   ██╔══██║██╔══╝  ██╔══██╗
        ██║  ██║███████╗   ██║   ██║  ██║███████╗██║  ██║
        ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                    AETHER HUB - Blox Fruits
                  Version 3.0.0 PROFESSIONAL EDITION
    ================================================================
    
    PROFESSIONAL FEATURES:
    ✓ Advanced Fast Attack (CombatFramework)
    ✓ Quest System with Auto Detection
    ✓ Bring Mob System (Magnetization)
    ✓ Complete Auto Farm Level
    ✓ Bypass Teleport System
    ✓ Network Ownership Detection
    ✓ Performance Optimizations
    
    BASED ON: Silver Hub Professional Techniques
]]

--// CONFIGURATION
local REPO_BASE = "https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/"
local VERSION = "3.0.0 PROFESSIONAL"
local DEBUG_MODE = false

--// UTILITIES
local function log(message, level)
    level = level or "INFO"
    local prefix = string.format("[AETHER HUB - %s]", level)
    print(prefix, message)
end

local function logError(message, err)
    warn(string.format("[AETHER HUB - ERROR] %s: %s", message, tostring(err)))
end

--[[
    Safe Module Loader
]]
local function loadModule(path, required)
    required = required or false
    log(string.format("Loading: %s", path))
    
    local success, result = pcall(function()
        local code = game:HttpGet(REPO_BASE .. path, true)
        local moduleFunc = loadstring(code)
        
        if not moduleFunc then
            error("Failed to compile module")
        end
        
        return moduleFunc()
    end)
    
    if success then
        log(string.format("✓ Loaded: %s", path), "SUCCESS")
        return result
    else
        local errorMsg = string.format("Failed to load: %s", path)
        
        if required then
            error(errorMsg .. " (CRITICAL MODULE)")
        else
            logError(errorMsg, result)
        end
        
        return nil
    end
end

--[[
    Health Check
]]
local function performHealthCheck()
    if not game:GetService("Players").LocalPlayer then
        return false, "Must run on client side"
    end
    
    local validPlaceIds = {2753915549, 4442272183, 7449423635}
    local isValid = false
    
    for _, id in ipairs(validPlaceIds) do
        if game.PlaceId == id then
            isValid = true
            break
        end
    end
    
    if not isValid then
        return false, "Not in Blox Fruits game"
    end
    
    return true
end

--[[
    Main Initialization
]]
local function main()
    log("=".rep(60))
    log(string.format("AETHER HUB v%s - Starting...", VERSION))
    log("=".rep(60))
    
    -- Health check
    local healthy, healthError = performHealthCheck()
    if not healthy then
        error(string.format("[HEALTH CHECK FAILED] %s", healthError))
    end
    
    log("✓ Health check passed")
    
    --// PHASE 1: Load Core Modules
    log("\n[PHASE 1] Loading Core Modules...")
    
    local Services = loadModule("Modules/Core/Services.lua", true)
    local Variables = loadModule("Modules/Core/Variables.lua", true)
    
    if not Services or not Variables then
        error("Failed to load core modules")
    end
    
    --// PHASE 2: Load Utility Modules
    log("\n[PHASE 2] Loading Utility Modules...")
    
    local Teleporter = loadModule("Modules/Teleport/Teleporter.lua", true)
    if Teleporter then
        Teleporter = Teleporter.new(Services)
    end
    
    --// PHASE 3: Load Advanced Systems
    log("\n[PHASE 3] Loading Advanced Systems...")
    
    -- Fast Attack System
    local FastAttack = loadModule("Modules/Combat/FastAttack.lua", false)
    if FastAttack then
        FastAttack = FastAttack.new(Services, Variables)
    end
    
    -- Quest System
    local QuestSystem = loadModule("Modules/Quest/QuestSystem.lua", false)
    if QuestSystem then
        QuestSystem = QuestSystem.new(Services)
    end
    
    -- Bring Mob System
    local BringMob = loadModule("Modules/Combat/BringMob.lua", false)
    if BringMob then
        BringMob = BringMob.new(Services, Variables)
    end
    
    -- Auto Farm Level (Complete)
    local AutoFarmLevel = loadModule("Modules/Combat/AutoFarmLevel.lua", false)
    if AutoFarmLevel and Teleporter and QuestSystem and FastAttack and BringMob then
        AutoFarmLevel = AutoFarmLevel.new(Services, Variables, Teleporter, QuestSystem, FastAttack, BringMob)
    end
    
    --// PHASE 4: Load Feature Modules
    log("\n[PHASE 4] Loading Feature Modules...")
    
    local FruitFinder = loadModule("Modules/Fruit/FruitFinder.lua", false)
    if FruitFinder then
        FruitFinder = FruitFinder.new(Services)
    end
    
    local FruitStorage = loadModule("Modules/Fruit/FruitStorage.lua", false)
    if FruitStorage then
        FruitStorage = FruitStorage.new(Services)
    end
    
    local FruitTeleport = loadModule("Modules/Fruit/FruitTeleport.lua", false)
    if FruitTeleport and FruitFinder and Teleporter then
        FruitTeleport = FruitTeleport.new(Services, Variables, Teleporter, FruitFinder, FruitStorage)
    end
    
    local AutoFarm = loadModule("Modules/Combat/AutoFarm.lua", false)
    if AutoFarm then
        AutoFarm = AutoFarm.new(Services, Variables, Teleporter)
    end
    
    --// PHASE 5: Setup Event Listeners
    log("\n[PHASE 5] Setting up Event Listeners...")
    
    if FruitFinder then
        FruitFinder:OnFruitSpawn(function(fruit)
            log(string.format("🍇 Fruit Spawned: %s", fruit.Name), "EVENT")
            
            if Variables:Get("FruitTeleport") and Teleporter then
                Teleporter:TeleportToInstance(fruit)
            end
        end)
    end
    
    --// PHASE 6: Load UI
    log("\n[PHASE 6] Loading Starlight UI...")
    
    local UI_SUCCESS = pcall(function()
        local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
        local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
        
        --// Create Window
        local Window = Starlight:CreateWindow({
            Name = "AETHER HUB PROFESSIONAL",
            Subtitle = string.format("v%s", VERSION),
            Icon = 0,
            LoadingEnabled = true,
            LoadingSettings = {
                Title = "AETHER HUB",
                Subtitle = "Initializing professional systems...",
            },
            FileSettings = {
                ConfigFolder = "AetherHubPro"
            }
        })
        
        --// ========== HOME TAB ==========
        local MainSection = Window:CreateTabSection("", false)
        local HomeTab = MainSection:CreateTab({
            Name = "Home",
            Icon = NebulaIcons:GetIcon("home", "Lucide"),
            Columns = 1
        }, "HomeTab")
        
        local InfoBox = HomeTab:CreateGroupbox({Name = "System Info"})
        InfoBox:CreateLabel("AETHER HUB PROFESSIONAL")
        InfoBox:CreateLabel("Version: " .. VERSION)
        InfoBox:CreateLabel("World: " .. (Variables.World or "Unknown"))
        
        if AutoFarmLevel then
            InfoBox:CreateLabel("Level: " .. tostring(AutoFarmLevel:GetLevel()))
        end
        
        if QuestSystem then
            local quest = QuestSystem:GetCurrentQuest()
            InfoBox:CreateLabel("Current Quest: " .. (quest and quest.QuestName or "None"))
        end
        
        --// ========== COMBAT TAB ==========
        local FeaturesSection = Window:CreateTabSection("Features")
        local CombatTab = FeaturesSection:CreateTab({
            Name = "Combat",
            Icon = NebulaIcons:GetIcon("swords", "Lucide"),
            Columns = 1
        }, "CombatTab")
        
        local FarmBox = CombatTab:CreateGroupbox({Name = "Auto Farm (Professional)"})
        
        if AutoFarmLevel then
            FarmBox:CreateToggle({
                Name = "Auto Farm Level (Quest System)",
                CurrentValue = false,
                Callback = function(value)
                    if value then
                        AutoFarmLevel:Start()
                    else
                        AutoFarmLevel:Stop()
                    end
                end
            }, "AutoFarmLevelToggle")
            
            FarmBox:CreateButton({
                Name = "View Farm Stats",
                Callback = function()
                    local stats = AutoFarmLevel:GetStats()
                    local message = string.format(
                        "Level: %d\nQuest: %s\nActive: %s\nFast Attack: %s\nBring Mob: %s",
                        stats.Level,
                        stats.CurrentQuest,
                        tostring(stats.QuestActive),
                        tostring(stats.FastAttack),
                        tostring(stats.BringMob)
                    )
                    
                    Starlight:Notify({
                        Title = "Farm Stats",
                        Content = message,
                        Duration = 5
                    })
                end
            }, "FarmStatsBtn")
        else
            FarmBox:CreateLabel("AutoFarmLevel not available")
        end
        
        --// Fast Attack Settings
        local FastAttackBox = CombatTab:CreateGroupbox({Name = "Fast Attack System"})
        
        if FastAttack then
            FastAttackBox:CreateToggle({
                Name = "Enable Fast Attack",
                CurrentValue = false,
                Callback = function(value)
                    if value then
                        FastAttack:Enable()
                    else
                        FastAttack:Disable()
                    end
                end
            }, "FastAttackToggle")
            
            FastAttackBox:CreateDropdown({
                Name = "Attack Mode",
                List = {"Fast", "Normal", "Slow"},
                Default = "Fast",
                Callback = function(value)
                    FastAttack:SetMode(value)
                end
            }, "AttackModeDropdown")
            
            FastAttackBox:CreateSlider({
                Name = "Hitbox Size",
                Min = 10,
                Max = 100,
                Default = 60,
                Callback = function(value)
                    FastAttack:SetHitboxSize(value)
                end
            }, "HitboxSlider")
        end
        
        --// Bring Mob Settings
        local BringMobBox = CombatTab:CreateGroupbox({Name = "Bring Mob System"})
        
        if BringMob then
            BringMobBox:CreateSlider({
                Name = "Bring Radius",
                Min = 100,
                Max = 1000,
                Default = 400,
                Callback = function(value)
                    BringMob:SetRadius(value)
                end
            }, "BringRadiusSlider")
            
            BringMobBox:CreateButton({
                Name = "View Bring Stats",
                Callback = function()
                    local stats = BringMob:GetStats()
                    Starlight:Notify({
                        Title = "Bring Mob Stats",
                        Content = string.format("Bringing: %d mobs\nRadius: %d", 
                            stats.CurrentlyBringing, stats.BringRadius),
                        Duration = 3
                    })
                end
            }, "BringStatsBtn")
        end
        
        --// ========== FRUIT TAB ==========
        local FruitTab = FeaturesSection:CreateTab({
            Name = "Fruit",
            Icon = NebulaIcons:GetIcon("cherry", "Lucide"),
            Columns = 1
        }, "FruitTab")
        
        local FruitBox = FruitTab:CreateGroupbox({Name = "Devil Fruit"})
        
        if FruitTeleport then
            FruitBox:CreateToggle({
                Name = "Auto TP to Fruit",
                CurrentValue = false,
                Callback = function(value)
                    if value then
                        FruitTeleport:Start()
                    else
                        FruitTeleport:Stop()
                    end
                end
            }, "FruitTPToggle")
        end
        
        if FruitFinder and Teleporter then
            FruitBox:CreateButton({
                Name = "TP to Closest Fruit",
                Callback = function()
                    local fruit, distance = FruitFinder:GetClosestFruit()
                    if fruit then
                        Teleporter:TeleportToInstance(fruit.Instance)
                        Starlight:Notify({
                            Title = "Teleporting",
                            Content = string.format("%s (%.1fm)", fruit.Name, distance or 0),
                            Duration = 3
                        })
                    else
                        Starlight:Notify({
                            Title = "No Fruit",
                            Content = "No fruits found in map",
                            Duration = 3
                        })
                    end
                end
            }, "TPFruitBtn")
            
            FruitBox:CreateButton({
                Name = "Find Rarest Fruit",
                Callback = function()
                    local fruit = FruitFinder:GetRarestFruit()
                    if fruit then
                        Teleporter:TeleportToInstance(fruit.Instance)
                        Starlight:Notify({
                            Title = "Rarest Fruit",
                            Content = string.format("%s (Rarity: %d)", fruit.Name, fruit.Rarity),
                            Duration = 3
                        })
                    else
                        Starlight:Notify({
                            Title = "No Fruit",
                            Content = "No fruits available",
                            Duration = 3
                        })
                    end
                end
            }, "RarestFruitBtn")
        end
        
        if FruitStorage then
            FruitBox:CreateToggle({
                Name = "Auto Store Fruits",
                CurrentValue = false,
                Callback = function(value)
                    Variables:Set("FruitAutoStore", value)
                end
            }, "AutoStoreToggle")
            
            FruitBox:CreateButton({
                Name = "Store Fruit Now",
                Callback = function()
                    local success, message = FruitStorage:StoreFruit()
                    Starlight:Notify({
                        Title = success and "Success" or "Error",
                        Content = message,
                        Duration = 3
                    })
                end
            }, "StoreFruitBtn")
        end
        
        --// ========== SETTINGS TAB ==========
        local SettingsSection = Window:CreateTabSection("Settings")
        local SettingsTab = SettingsSection:CreateTab({
            Name = "Config",
            Icon = NebulaIcons:GetIcon("settings", "Lucide"),
            Columns = 1
        }, "SettingsTab")
        
        local ConfigBox = SettingsTab:CreateGroupbox({Name = "Configuration"})
        
        ConfigBox:CreateToggle({
            Name = "Bypass TP (Long Distance)",
            CurrentValue = false,
            Callback = function(value)
                Variables:Set("BypassTP", value)
            end
        }, "BypassTPToggle")
        
        ConfigBox:CreateDropdown({
            Name = "Select Weapon Type",
            List = {"Melee", "Sword", "Fruit"},
            Default = "Melee",
            Callback = function(value)
                Variables:Set("WeaponType", value)
            end
        }, "WeaponTypeDropdown")
        
        SettingsTab:BuildConfigSection()
        SettingsTab:BuildThemeSection()
        
        --// SUCCESS NOTIFICATION
        Starlight:Notify({
            Title = "AETHER HUB PROFESSIONAL",
            Content = "All systems loaded successfully!",
            Duration = 5
        })
    end)
    
    if not UI_SUCCESS then
        warn("[AETHER HUB] UI failed to load, running in headless mode")
    end
    
    --// COMPLETE
    log("\n" .. "=".rep(60))
    log(string.format("✓ AETHER HUB v%s loaded successfully!", VERSION), "SUCCESS")
    log("=".rep(60))
    
    -- Print feature summary
    log("\n📋 LOADED FEATURES:")
    log("  ✓ Fast Attack System (CombatFramework)")
    log("  ✓ Quest System (Auto Detection)")
    log("  ✓ Bring Mob System (Magnetization)")
    log("  ✓ Auto Farm Level (Complete)")
    log("  ✓ Fruit Finder & Storage")
    log("  ✓ Advanced Teleportation")
    log("=".rep(60))
end

--// EXECUTE WITH GLOBAL ERROR HANDLER
local success, error = pcall(main)

if not success then
    logError("Fatal error during initialization", error)
end