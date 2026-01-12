--[[
    AETHER HUB - Variables Module (v3.1 - Simplified)
    Global settings and state management
]]

local Variables = {}

-- Detect World
local function detectWorld()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return "Sea 1"
    elseif placeId == 4442272183 then return "Sea 2"
    elseif placeId == 7449423635 then return "Sea 3"
    else return "Unknown"
    end
end

-- State
local _state = {
    -- Feature Toggles
    AutoFarm = false,
    AutoMastery = false,
    AutoQuest = false,
    FruitTeleport = false,
    FruitAutoStore = false,
    ESP = false,
    
    -- Settings
    FarmDistance = 200,
    AttackDelay = 0.1,
    TeleportDelay = 0.5,
    
    -- World Info
    World = detectWorld(),
    PlaceId = game.PlaceId
}

-- Listeners
local _listeners = {}

-- Set value
function Variables:Set(key, value)
    if key == "World" or key == "PlaceId" then
        return false
    end
    
    local oldValue = _state[key]
    _state[key] = value
    
    -- Notify listeners
    if _listeners[key] then
        for _, callback in ipairs(_listeners[key]) do
            pcall(callback, value, oldValue)
        end
    end
    
    return true
end

-- Get value
function Variables:Get(key)
    return _state[key]
end

-- Register listener
function Variables:OnChanged(key, callback)
    if not _listeners[key] then
        _listeners[key] = {}
    end
    table.insert(_listeners[key], callback)
    
    return function()
        for i, cb in ipairs(_listeners[key]) do
            if cb == callback then
                table.remove(_listeners[key], i)
                break
            end
        end
    end
end

-- Direct access via metatable
setmetatable(Variables, {
    __index = function(_, key)
        return _state[key]
    end,
    __newindex = function(_, key, value)
        Variables:Set(key, value)
    end
})

return Variables