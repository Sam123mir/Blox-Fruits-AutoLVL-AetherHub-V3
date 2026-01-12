--[[
    ================================================================
         AETHER HUB - UI Configuration (v3.0)
    ================================================================
    
    Central configuration for Starlight UI settings
    
    FEATURES:
    ✓ Theme configuration
    ✓ Window settings
    ✓ Tab definitions
    ✓ Icon mappings
    ✓ Color presets
    ✓ Responsive layouts
]]

local UIConfig = {}

--// VERSION INFO
UIConfig.Version = "3.0.0"
UIConfig.Author = "AETHER Team"
UIConfig.LastUpdated = "2026-01-11"

--// WINDOW SETTINGS
UIConfig.Window = {
    Name = "AETHER HUB",
    Subtitle = "Blox Fruits v3.0.0",
    Icon = 0, -- Roblox asset ID (0 = none)
    LogoUrl = "", -- Custom logo URL if needed
    
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "AETHER HUB",
        Subtitle = "Loading systems...",
        AnimationSpeed = 1,
        ShowProgressBar = true
    },
    
    FileSettings = {
        ConfigFolder = "AetherHub",
        RootFolder = "AetherScripts",
        ConfigFile = "config.json",
        ThemeFile = "theme.json"
    },
    
    -- Performance settings
    NotifyOnCallbackError = true,
    BuildWarnings = false,
    UpdateRate = 60 -- FPS cap for UI updates
}

--// TAB SECTIONS CONFIGURATION
UIConfig.Sections = {
    {
        Name = "",
        Visible = false,
        Tabs = {
            {
                Name = "Home",
                Icon = "home",
                IconSource = "Lucide",
                Columns = 1,
                Description = "Dashboard and system info"
            }
        }
    },
    {
        Name = "Features",
        Visible = true,
        Tabs = {
            {
                Name = "Combat",
                Icon = "swords",
                IconSource = "Lucide",
                Columns = 1,
                Description = "Auto farm and combat settings"
            },
            {
                Name = "Fruit",
                Icon = "cherry",
                IconSource = "Lucide",
                Columns = 1,
                Description = "Devil fruit finder and storage"
            },
            {
                Name = "Mastery",
                Icon = "zap",
                IconSource = "Lucide",
                Columns = 1,
                Description = "Auto mastery farming"
            }
        }
    },
    {
        Name = "Teleport",
        Visible = true,
        Tabs = {
            {
                Name = "Islands",
                Icon = "map-pin",
                IconSource = "Lucide",
                Columns = 2,
                Description = "Quick island teleports"
            },
            {
                Name = "NPCs",
                Icon = "users",
                IconSource = "Lucide",
                Columns = 2,
                Description = "Teleport to quest givers"
            }
        }
    },
    {
        Name = "Misc",
        Visible = true,
        Tabs = {
            {
                Name = "ESP",
                Icon = "eye",
                IconSource = "Lucide",
                Columns = 1,
                Description = "Visual enhancements"
            },
            {
                Name = "Stats",
                Icon = "bar-chart",
                IconSource = "Lucide",
                Columns = 1,
                Description = "Statistics and analytics"
            }
        }
    },
    {
        Name = "Settings",
        Visible = true,
        Tabs = {
            {
                Name = "Config",
                Icon = "settings",
                IconSource = "Lucide",
                Columns = 1,
                Description = "Save and load configurations"
            },
            {
                Name = "About",
                Icon = "info",
                IconSource = "Lucide",
                Columns = 1,
                Description = "About AETHER HUB"
            }
        }
    }
}

--// COLOR THEMES
UIConfig.Themes = {
    Default = {
        Primary = Color3.fromRGB(0, 170, 127),      -- Teal/Green
        Secondary = Color3.fromRGB(0, 140, 100),
        Accent = Color3.fromRGB(0, 255, 170),
        Background = Color3.fromRGB(20, 20, 30),
        Surface = Color3.fromRGB(30, 30, 45),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(0, 255, 100),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 50, 50)
    },
    
    Green = {
        Primary = Color3.fromRGB(0, 255, 127),      -- Spring Green
        Secondary = Color3.fromRGB(0, 200, 100),
        Accent = Color3.fromRGB(50, 255, 150),
        Background = Color3.fromRGB(15, 25, 20),
        Surface = Color3.fromRGB(25, 40, 30),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 200, 170),
        Success = Color3.fromRGB(0, 255, 100),
        Warning = Color3.fromRGB(255, 220, 0),
        Error = Color3.fromRGB(255, 80, 80)
    },
    
    Neon = {
        Primary = Color3.fromRGB(0, 255, 255),      -- Cyan
        Secondary = Color3.fromRGB(255, 0, 255),     -- Magenta
        Accent = Color3.fromRGB(255, 255, 0),        -- Yellow
        Background = Color3.fromRGB(10, 10, 20),
        Surface = Color3.fromRGB(20, 20, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 255),
        Success = Color3.fromRGB(0, 255, 200),
        Warning = Color3.fromRGB(255, 255, 100),
        Error = Color3.fromRGB(255, 100, 255)
    },
    
    Dark = {
        Primary = Color3.fromRGB(100, 100, 100),
        Secondary = Color3.fromRGB(80, 80, 80),
        Accent = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(10, 10, 10),
        Surface = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 150),
        Success = Color3.fromRGB(100, 200, 100),
        Warning = Color3.fromRGB(200, 200, 100),
        Error = Color3.fromRGB(200, 100, 100)
    },
    
    Ocean = {
        Primary = Color3.fromRGB(0, 120, 215),      -- Ocean Blue
        Secondary = Color3.fromRGB(0, 90, 180),
        Accent = Color3.fromRGB(0, 180, 255),
        Background = Color3.fromRGB(10, 20, 30),
        Surface = Color3.fromRGB(20, 35, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 180, 200),
        Success = Color3.fromRGB(0, 200, 150),
        Warning = Color3.fromRGB(255, 180, 0),
        Error = Color3.fromRGB(220, 50, 80)
    }
}

--// CURRENT THEME
UIConfig.CurrentTheme = "Green" -- User's preferred theme

--// NOTIFICATION SETTINGS
UIConfig.Notifications = {
    Duration = 5,
    Position = "TopRight", -- TopRight, TopLeft, BottomRight, BottomLeft
    MaxVisible = 3,
    AnimationSpeed = 0.3,
    ShowTimestamp = true
}

--// KEYBINDS
UIConfig.Keybinds = {
    ToggleUI = Enum.KeyCode.RightControl,
    ToggleAutoFarm = Enum.KeyCode.F,
    ToggleFruitTP = Enum.KeyCode.G,
    Teleport = Enum.KeyCode.T,
    EmergencyStop = Enum.KeyCode.X
}

--// LAYOUT PRESETS
UIConfig.Layouts = {
    Compact = {
        WindowSize = UDim2.new(0, 500, 0, 400),
        TabWidth = 120,
        GroupboxPadding = 5
    },
    Standard = {
        WindowSize = UDim2.new(0, 600, 0, 500),
        TabWidth = 150,
        GroupboxPadding = 10
    },
    Large = {
        WindowSize = UDim2.new(0, 800, 0, 600),
        TabWidth = 180,
        GroupboxPadding = 15
    }
}

UIConfig.CurrentLayout = "Standard"

--// HELPER FUNCTIONS

--[[
    Get theme by name
    @param themeName string?
    @return table - Theme colors
]]
function UIConfig:GetTheme(themeName)
    return self.Themes[themeName or self.CurrentTheme] or self.Themes.Default
end

--[[
    Get current active theme
    @return table - Theme colors
]]
function UIConfig:GetCurrentTheme()
    return self:GetTheme(self.CurrentTheme)
end

--[[
    Set active theme
    @param themeName string
    @return boolean - success
]]
function UIConfig:SetTheme(themeName)
    if self.Themes[themeName] then
        self.CurrentTheme = themeName
        print(string.format("[UICONFIG] Theme changed to: %s", themeName))
        return true
    end
    warn(string.format("[UICONFIG] Theme not found: %s", themeName))
    return false
end

--[[
    Get keybind for action
    @param action string
    @return Enum.KeyCode?
]]
function UIConfig:GetKeybind(action)
    return self.Keybinds[action]
end

--[[
    Set custom keybind
    @param action string
    @param keyCode Enum.KeyCode
    @return boolean
]]
function UIConfig:SetKeybind(action, keyCode)
    if self.Keybinds[action] ~= nil then
        self.Keybinds[action] = keyCode
        print(string.format("[UICONFIG] Keybind updated: %s = %s", action, keyCode.Name))
        return true
    end
    return false
end

--[[
    Get layout preset
    @param layoutName string?
    @return table
]]
function UIConfig:GetLayout(layoutName)
    return self.Layouts[layoutName or self.CurrentLayout] or self.Layouts.Standard
end

--[[
    List all available themes
    @return table - Array of theme names
]]
function UIConfig:GetAvailableThemes()
    local themes = {}
    for name, _ in pairs(self.Themes) do
        table.insert(themes, name)
    end
    return themes
end

--[[
    Validate configuration
    @return boolean, string?
]]
function UIConfig:Validate()
    -- Check required fields
    if not self.Window or not self.Window.Name then
        return false, "Window configuration missing"
    end
    
    if not self.CurrentTheme or not self.Themes[self.CurrentTheme] then
        return false, "Invalid theme selected"
    end
    
    if #self.Sections == 0 then
        return false, "No sections configured"
    end
    
    return true, "Configuration valid"
end

--[[
    Export configuration as JSON-compatible table
    @return table
]]
function UIConfig:Export()
    return {
        Version = self.Version,
        CurrentTheme = self.CurrentTheme,
        CurrentLayout = self.CurrentLayout,
        Keybinds = self.Keybinds,
        Notifications = self.Notifications
    }
end

--[[
    Debug print
]]
function UIConfig:Debug()
    print("=== UI CONFIGURATION ===")
    print("Version:", self.Version)
    print("Current Theme:", self.CurrentTheme)
    print("Current Layout:", self.CurrentLayout)
    print("Sections:", #self.Sections)
    print("========================")
end

return UIConfig