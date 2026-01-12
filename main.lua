--[[
    ================================================================
         █████╗ ███████╗████████╗██╗  ██╗███████╗██████╗ 
        ██╔══██╗██╔════╝╚══██╔══╝██║  ██║██╔════╝██╔══██╗
        ███████║█████╗     ██║   ███████║█████╗  ██████╔╝
        ██╔══██║██╔══╝     ██║   ██╔══██║██╔══╝  ██╔══██╗
        ██║  ██║███████╗   ██║   ██║  ██║███████╗██║  ██║
        ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                    AETHER HUB - Blox Fruits
                      Version 3.0.0 REFACTORED
    ================================================================
    
    ARQUITECTURA PROFESIONAL:
    ✓ Dependency Injection Pattern
    ✓ Error Boundaries
    ✓ Lazy Loading
    ✓ Health Checks
    ✓ Graceful Degradation
]]

--// CONFIGURATION
local REPO_BASE = "https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/"
local VERSION = "3.0.0"
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
    Safe Module Loader con error handling
    @param path string - Module path
    @param required boolean - Is this module critical?
    @return table? - Module or nil
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
    Health Check - Verify environment
    @return boolean, string?
]]
local function performHealthCheck()
    -- Check if running on client
    if not game:GetService("Players").LocalPlayer then
        return false, "Must run on client side"
    end
    
    -- Check if in Blox Fruits
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
    
    --// PHASE 1: Load Core Modules (Critical)
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
    
    --// PHASE 3: Load Feature Modules
    log("\n[PHASE 3] Loading Feature Modules...")
    
    local FruitFinder = loadModule("Modules/Fruit/FruitFinder.lua", false)
    if FruitFinder then
        FruitFinder = FruitFinder.new(Services)
    end
    
    local FruitStorage = loadModule("Modules/Fruit/FruitStorage.lua", false)
    if FruitStorage then
        FruitStorage = FruitStorage.new(Services)
    end
    
    local AutoFarm = loadModule("Modules/Combat/AutoFarm.lua", false)
    if AutoFarm then
        AutoFarm = AutoFarm.new(Services, Variables, Teleporter)
    end
    
    local FruitTeleport = loadModule("Modules/Teleport/FruitTeleport.lua", false)
    if FruitTeleport and FruitFinder and Teleporter then
        FruitTeleport = FruitTeleport.new(Services, Variables, Teleporter, FruitFinder, FruitStorage)
    end
    
    --// PHASE 4: Setup Event Listeners
    log("\n[PHASE 4] Setting up Event Listeners...")
    
    if FruitFinder then
        FruitFinder:OnFruitSpawn(function(fruit)
            log(string.format("🍇 Fruit Spawned: %s", fruit.Name), "EVENT")
            
            -- Auto teleport if enabled (now handled by FruitTeleport module)
            if FruitTeleport and Variables:Get("FruitTeleport") then
                -- FruitTeleport handles this automatically
            end
        end)
    end
    
    --// PHASE 5: Load UI
    log("\n[PHASE 5] Loading Starlight UI...")
    
    local UI_SUCCESS = pcall(function()
        local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
        local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
        
        --// Create Window
        local Window = Starlight:CreateWindow({
            Name = "AETHER HUB",
            Subtitle = string.format("Blox Fruits v%s", VERSION),
            Icon = 0,
            LoadingEnabled = true,
            LoadingSettings = {
                Title = "AETHER HUB",
                Subtitle = "Initializing systems...",
            },
            FileSettings = {
                ConfigFolder = "AetherHub"
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
        InfoBox:CreateLabel("AETHER HUB v" .. VERSION)
        InfoBox:CreateLabel("World: " .. (Variables.World or "Unknown"))
        InfoBox:CreateLabel("Level: " .. (AutoFarm and tostring(AutoFarm:GetLevel()) or "0"))
        
        --// ========== COMBAT TAB ==========
        local FeaturesSection = Window:CreateTabSection("Features")
        local CombatTab = FeaturesSection:CreateTab({
            Name = "Combat",
            Icon = NebulaIcons:GetIcon("swords", "Lucide"),
            Columns = 1
        }, "CombatTab")
        
        local FarmBox = CombatTab:CreateGroupbox({Name = "Auto Farm"})
        
        if AutoFarm then
            FarmBox:CreateToggle({
                Name = "Auto Farm Level",
                CurrentValue = false,
                Callback = function(value)
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
                    Variables:Set("FarmDistance", value)
                end
            }, "FarmDistanceSlider")
        else
            FarmBox:CreateLabel("AutoFarm module not available")
        end
        
        --// ========== FRUIT TAB ==========
        local FruitTab = FeaturesSection:CreateTab({
            Name = "Fruit",
            Icon = NebulaIcons:GetIcon("cherry", "Lucide"),
            Columns = 1
        }, "FruitTab")
        
        local FruitBox = FruitTab:CreateGroupbox({Name = "Devil Fruit"})
        
        if FruitFinder and Teleporter then
            FruitBox:CreateToggle({
                Name = "Auto TP to Fruit",
                CurrentValue = false,
                Callback = function(value)
                    Variables:Set("FruitTeleport", value)
                end
            }, "FruitTPToggle")
            
            FruitBox:CreateButton({
                Name = "TP to Closest Fruit",
                Callback = function()
                    local fruit, distance = FruitFinder:GetClosestFruit()
                    if fruit then
                        Teleporter:TeleportToInstance(fruit.Instance)
                        Starlight:Notify({
                            Title = "Teleporting",
                            Content = string.format("%s (%.1fm)", fruit.Name, distance),
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
        end
        
        if FruitStorage then
            FruitBox:CreateButton({
                Name = "Store Fruit",
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
        
        SettingsTab:BuildConfigSection()
        SettingsTab:BuildThemeSection()
        
        --// SUCCESS NOTIFICATION
        Starlight:Notify({
            Title = "AETHER HUB",
            Content = "Loaded successfully!",
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
end

--// EXECUTE WITH GLOBAL ERROR HANDLER
local success, error = pcall(main)

if not success then
    logError("Fatal error during initialization", error)
end