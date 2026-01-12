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
]]

local UIConfig = {}

--// VERSION
UIConfig.Version = "3.0.0"

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
        AnimationSpeed = 1
    },
    
    FileSettings = {
        ConfigFolder = "AetherHub",
        RootFolder = "AetherScripts"
    },
    
    -- Performance settings
    NotifyOnCallbackError = true,
    BuildWarnings = false
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
                Columns = 1
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
                Columns = 1
            },
            {
                Name = "Fruit",
                Icon = "cherry",
                IconSource = "Lucide",
                Columns = 1
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
                Columns = 2
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
                Columns = 1
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
        TextSecondary = Color3.fromRGB(180, 180, 180)
    },
    Green = {
        Primary = Color3.fromRGB(0, 255, 127),      -- Spring Green
        Secondary = Color3.fromRGB(0, 200, 100),
        Accent = Color3.fromRGB(50, 255, 150),
        Background = Color3.fromRGB(15, 25, 20),
        Surface = Color3.fromRGB(25, 40, 30),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 200, 170)
    },
    Neon = {
        Primary = Color3.fromRGB(0, 255, 255),      -- Cyan
        Secondary = Color3.fromRGB(255, 0, 255),     -- Magenta
        Accent = Color3.fromRGB(255, 255, 0),        -- Yellow
        Background = Color3.fromRGB(10, 10, 20),
        Surface = Color3.fromRGB(20, 20, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 255)
    },
    Dark = {
        Primary = Color3.fromRGB(100, 100, 100),
        Secondary = Color3.fromRGB(80, 80, 80),
        Accent = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(10, 10, 10),
        Surface = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 150)
    }
}

--// CURRENT THEME
UIConfig.CurrentTheme = "Green" -- User's preferred theme

--// NOTIFICATION SETTINGS
UIConfig.Notifications = {
    Duration = 5,
    Position = "TopRight", -- TopRight, TopLeft, BottomRight, BottomLeft
    MaxVisible = 3
}

--// KEYBINDS
UIConfig.Keybinds = {
    ToggleUI = Enum.KeyCode.RightControl,
    ToggleAutoFarm = Enum.KeyCode.F,
    ToggleFruitTP = Enum.KeyCode.G,
    Teleport = Enum.KeyCode.T
}

--// HELPER FUNCTIONS
function UIConfig:GetTheme(themeName)
    return self.Themes[themeName or self.CurrentTheme] or self.Themes.Default
end

function UIConfig:GetCurrentTheme()
    return self:GetTheme(self.CurrentTheme)
end

function UIConfig:SetTheme(themeName)
    if self.Themes[themeName] then
        self.CurrentTheme = themeName
        return true
    end
    return false
end

function UIConfig:GetKeybind(action)
    return self.Keybinds[action]
end

return UIConfig
