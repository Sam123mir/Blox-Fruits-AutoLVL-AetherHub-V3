--[[
    AETHER HUB - UI Configuration
    Starlight UI settings and theme
]]

local UIConfig = {}

-- Window configuration
UIConfig.Window = {
    Name = "AETHER HUB",
    Subtitle = "Blox Fruits v2.0.0",
    Icon = 0, -- Bear icon ID (user can provide)
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "AETHER HUB",
        Subtitle = "Loading...",
    },
    FileSettings = {
        ConfigFolder = "AetherHub"
    }
}

-- Tab Sections
UIConfig.Sections = {
    Main = "Main",
    Features = "Features",
    Teleport = "Teleport",
    Settings = "Settings"
}

-- Colors (Green theme)
UIConfig.Colors = {
    Primary = Color3.fromRGB(0, 255, 127),      -- Spring Green
    Secondary = Color3.fromRGB(0, 200, 100),
    Background = Color3.fromRGB(20, 20, 30),
    Text = Color3.fromRGB(255, 255, 255)
}

return UIConfig
