--[[
    AETHER HUB - ENTERPRISE BOOTSTRAP v5.1
    ============================================================================
    Punto de entrada principal del sistema. 
    Responsable de la orquestación de módulos y gestión del ciclo de vida.
    
    ARQUITECTURA:
    - Depedency Injection Hub
    - Graceful Error Handling
    - Environment Validation
]]

--// Core Initialization
local function Bootstrap()
    print("[AETHER] Starting Enterprise Bootstrap...")
    
    local success, err = pcall(function()
        -- 1. Load Core Systems (Singletons)
        -- Nota: Ajustado para usar la estructura de archivos local
        local ServicesModule = require(script.Modules.Core.Services)
        local VariablesModule = require(script.Modules.Core.Variables)
        
        local Services = ServicesModule() -- GetSingleton
        local Variables = VariablesModule(Services) -- GetSingleton
        
        -- 2. Load Feature Modules
        local QuestSystem = require(script.Modules.Quest.QuestSystem).new(Services, Variables)
        local FastAttack = require(script.Modules.Combat.FastAttack).new(Services, Variables)
        local BringMob = require(script.Modules.Combat.BringMob).new(Services, Variables)
        
        local AutoFarmLevel = require(script.Modules.Combat.AutoFarmLevel).new(
            Services, 
            Variables, 
            FastAttack, 
            BringMob, 
            QuestSystem
        )

        -- 3. Load UI (Integrated in bootstrap)
        local LunaUI = require(script.Modules.UI.LunaInterface).new(Services, Variables)
        
        -- 4. Global Registry
        _G.AetherHub = {
            Services = Services,
            Variables = Variables,
            UI = LunaUI,
            Modules = {
                Quest = QuestSystem,
                FastAttack = FastAttack,
                BringMob = BringMob,
                AutoFarm = AutoFarmLevel
            }
        }
        
        -- 4. Final Start
        task.spawn(function()
            -- Esperar a que el juego cargue completamente
            if not game:IsLoaded() then
                game.Loaded:Wait()
            end
            
            print("[AETHER] Hub bootstrapped successfully. Starting Farm...")
            
            -- Activar farm automáticamete si está configurado en Variables
            if Variables:Get("AutoFarmLevel") then
                AutoFarmLevel:Start()
            end
        end)
    end)
    
    if not success then
        warn("[AETHER] CRITICAL BOOTSTRAP ERROR: " .. tostring(err))
    end
end

-- Start
Bootstrap()

return _G.AetherHub