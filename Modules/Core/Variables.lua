--[[
    AETHER HUB - Variables Module
    Global variables and settings
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
Variables.World = nil
Variables.Sea1 = game.PlaceId == 2753915549
Variables.Sea2 = game.PlaceId == 4442272183
Variables.Sea3 = game.PlaceId == 7449423635

if Variables.Sea1 then
    Variables.World = "World1"
elseif Variables.Sea2 then
    Variables.World = "World2"
elseif Variables.Sea3 then
    Variables.World = "World3"
end

-- Player Data Cache
Variables.PlayerLevel = 0
Variables.PlayerRace = ""
Variables.PlayerBeli = 0
Variables.PlayerFragments = 0
Variables.CurrentFruit = nil

return Variables
