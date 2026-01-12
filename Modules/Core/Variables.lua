--[[
    AETHER HUB - Variables Module
    Global settings and state
    This module is standalone - no dependencies
]]

local Variables = {}

-- Feature Toggles
Variables.AutoFarm = false
Variables.AutoMastery = false
Variables.AutoQuest = false
Variables.FruitTeleport = false
Variables.FruitAutoStore = false
Variables.ESP = false

-- Settings
Variables.FarmDistance = 200
Variables.AttackDelay = 0.1
Variables.TeleportDelay = 0.5

-- World Detection
Variables.Sea1 = game.PlaceId == 2753915549
Variables.Sea2 = game.PlaceId == 4442272183
Variables.Sea3 = game.PlaceId == 7449423635

if Variables.Sea1 then
    Variables.World = "Sea 1"
elseif Variables.Sea2 then
    Variables.World = "Sea 2"
elseif Variables.Sea3 then
    Variables.World = "Sea 3"
else
    Variables.World = "Unknown"
end

return Variables
