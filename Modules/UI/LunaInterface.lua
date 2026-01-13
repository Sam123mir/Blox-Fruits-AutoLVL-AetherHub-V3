--[[
    AETHER HUB - LUNA INTERFACE v5.2
    ============================================================================
    Implementación de la interfaz de usuario utilizando Luna Interface Suite.
    Integración reactiva con el sistema de Variables y Servicios.
    
    INGENIERÍA:
    - Auto-binding a Variables.lua
    - Configuración centralizada
    - Notificaciones inteligentes
]]

local LunaInterface = {}
LunaInterface.__index = LunaInterface

--// Boot Luna (Remote Load)
local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna", true))()

--[[
    CONSTRUCTOR
]]
function LunaInterface.new(services, variables)
    local self = setmetatable({}, LunaInterface)
    
    self._services = services
    self._vars = variables
    self._tabs = {}
    self._elements = {}
    
    self:_initialize()
    
    print("[UI] Luna Interface Initialized")
    return self
end

--[[
    PRIVATE: Initialize Window and Tabs
]]
function LunaInterface:_initialize()
    -- 1. Create Window
    self._window = Luna:CreateWindow({
        Name = "AETHER HUB",
        Subtitle = "Enterprise Edition v5.2",
        LogoID = nil, -- Dejado para personalización futura
        LoadingEnabled = true,
        LoadingTitle = "AETHER HUB",
        LoadingSubtitle = "Preparing Enterprise Systems...",
        ConfigSettings = {
            ConfigFolder = "AetherHub_Configs"
        },
        KeySystem = false -- Podría habilitarse vía Variables
    })

    -- 2. Create Tabs
    self:_setupHomeTab()
    self:_setupCombatTab()
    self:_setupFruitTab()
    self:_setupQuestTab()
    self:_setupSettingsTab()

    -- 3. Finalize
    Luna:Notification({
        Title = "AETHER HUB v5.2",
        Content = "Enterprise UI Loaded Successfully!",
        Icon = "verified",
        ImageSource = "Material"
    })
end

--[[
    TAB SETUP: Home
]]
function LunaInterface:_setupHomeTab()
    local tab = self._window:CreateTab({
        Name = "Home",
        Icon = "home",
        ImageSource = "Material"
    })
    
    tab:CreateSection("System Info")
    
    tab:CreateLabel("Account: " .. self._services.LocalPlayer.Name)
    tab:CreateLabel("Current Sea: " .. self._vars.World)
    
    tab:CreateSection("Status")
    tab:CreateLabel("Coming Soon: Full Dashboard Statistics")
end

--[[
    TAB SETUP: Combat
]]
function LunaInterface:_setupCombatTab()
    local tab = self._window:CreateTab({
        Name = "Combat",
        Icon = "swords",
        ImageSource = "Lucide"
    })
    
    tab:CreateSection("Main Automation")
    
    self._elements.AutoFarm = tab:CreateToggle({
        Name = "Auto Farm Level",
        CurrentValue = self._vars:Get("AutoFarmLevel"),
        Callback = function(v)
            self._vars:Set("AutoFarmLevel", v)
        end
    }, "AutoFarmLevel")

    tab:CreateSection("Customization")
    
    tab:CreateToggle({
        Name = "Fast Attack",
        CurrentValue = self._vars:Get("FastAttack"),
        Callback = function(v)
            self._vars:Set("FastAttack", v)
        end
    }, "FastAttack")

    tab:CreateToggle({
        Name = "Bring Mob (Magnetism)",
        CurrentValue = self._vars:Get("BringMob"),
        Callback = function(v)
            self._vars:Set("BringMob", v)
        end
    }, "BringMob")
end

--[[
    TAB SETUP: Fruit
]]
function LunaInterface:_setupFruitTab()
    local tab = self._window:CreateTab({
        Name = "Fruit",
        Icon = "cherry",
        ImageSource = "Lucide"
    })
    
    tab:CreateSection("Management")
    
    tab:CreateToggle({
        Name = "Auto Store Fruit",
        CurrentValue = self._vars:Get("AutoStoreFruit"),
        Callback = function(v)
            self._vars:Set("AutoStoreFruit", v)
        end
    }, "AutoStoreFruit")

    tab:CreateToggle({
        Name = "Fruit Teleport",
        CurrentValue = self._vars:Get("FruitTeleport"),
        Callback = function(v)
            self._vars:Set("FruitTeleport", v)
        end
    }, "FruitTeleport")
end

--[[
    TAB SETUP: Quest
]]
function LunaInterface:_setupQuestTab()
    local tab = self._window:CreateTab({
        Name = "Quest",
        Icon = "description",
        ImageSource = "Material"
    })
    
    tab:CreateSection("Quest Selection")
    tab:CreateLabel("Coming Soon: Custom Quest Selector")
end

--[[
    TAB SETUP: Settings
]]
function LunaInterface:_setupSettingsTab()
    local tab = self._window:CreateTab({
        Name = "Settings",
        Icon = "settings",
        ImageSource = "Material"
    })
    
    tab:CreateSection("UI Settings")
    
    tab:CreateButton({
        Name = "Save Configuration",
        Callback = function()
            self._vars:SaveToDisk()
            Luna:Notification({
                Title = "Config Saved",
                Content = "Your settings have been stored permanently.",
                Icon = "save",
                ImageSource = "Material"
            })
        end
    })
    
    tab:CreateSection("Advanced")
    
    tab:CreateLabel("Framework: Luna Suite v6.1")
    tab:CreateLabel("Edition: Enterprise v5.2")
end

return LunaInterface
