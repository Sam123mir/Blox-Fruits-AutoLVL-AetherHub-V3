--[[
    ================================================================
         AETHER HUB - Variables Module (Refactored v3.0)
    ================================================================
    
    MEJORAS APLICADAS:
    ✓ Immutable configuration pattern
    ✓ Type-safe state management
    ✓ Change listeners (Observer pattern)
    ✓ Validation system
    ✓ Default value handling
    
    DEPENDENCIES: None (Core Module)
]]

--// STATE MANAGER
local Variables = {}
Variables.__index = Variables

--// PRIVATE STATE
local _state = {}
local _listeners = {}
local _defaults = {}

--// CONSTANTS
local PLACE_IDS = {
    SEA_1 = 2753915549,
    SEA_2 = 4442272183,
    SEA_3 = 7449423635
}

--[[
    Initialize default configuration
]]
local function initializeDefaults()
    _defaults = {
        -- Feature Toggles (boolean)
        AutoFarm = false,
        AutoMastery = false,
        AutoQuest = false,
        FruitTeleport = false,
        FruitAutoStore = false,
        ESP = false,
        
        -- Settings (number)
        FarmDistance = 200,
        AttackDelay = 0.1,
        TeleportDelay = 0.5,
        MaxAttackRange = 500,
        MinAttackRange = 50,
        
        -- World Info (readonly)
        World = detectWorld(),
        PlaceId = game.PlaceId,
        
        -- Performance
        FrameSkip = 1,
        UpdateRate = 0.1
    }
    
    -- Copy defaults to state
    for key, value in pairs(_defaults) do
        _state[key] = value
    end
end

--[[
    Detect current world/sea
    @return string
]]
function detectWorld()
    local placeId = game.PlaceId
    
    if placeId == PLACE_IDS.SEA_1 then
        return "Sea 1"
    elseif placeId == PLACE_IDS.SEA_2 then
        return "Sea 2"
    elseif placeId == PLACE_IDS.SEA_3 then
        return "Sea 3"
    else
        return "Unknown"
    end
end

--[[
    Validate value type
    @param key string
    @param value any
    @return boolean, string?
]]
local function validateValue(key, value)
    local defaultValue = _defaults[key]
    if not defaultValue then
        return false, string.format("Unknown key: %s", key)
    end
    
    local expectedType = type(defaultValue)
    local actualType = type(value)
    
    if expectedType ~= actualType then
        return false, string.format(
            "Type mismatch for %s: expected %s, got %s",
            key, expectedType, actualType
        )
    end
    
    -- Range validation for numbers
    if actualType == "number" then
        if key == "FarmDistance" then
            if value < 50 or value > 500 then
                return false, "FarmDistance must be between 50-500"
            end
        elseif key == "AttackDelay" then
            if value < 0.05 or value > 1 then
                return false, "AttackDelay must be between 0.05-1"
            end
        end
    end
    
    return true
end

--[[
    Set value with validation
    @param key string
    @param value any
    @return boolean - success
]]
function Variables:Set(key, value)
    -- Protect readonly keys
    if key == "World" or key == "PlaceId" then
        warn(string.format("[VARIABLES] Cannot modify readonly key: %s", key))
        return false
    end
    
    -- Validate
    local valid, error = validateValue(key, value)
    if not valid then
        warn(string.format("[VARIABLES] Validation failed: %s", error))
        return false
    end
    
    -- Check if value actually changed
    local oldValue = _state[key]
    if oldValue == value then
        return true -- No change needed
    end
    
    -- Update state
    _state[key] = value
    
    -- Notify listeners
    if _listeners[key] then
        for _, callback in ipairs(_listeners[key]) do
            task.spawn(callback, value, oldValue)
        end
    end
    
    return true
end

--[[
    Get value
    @param key string
    @return any?
]]
function Variables:Get(key)
    return _state[key]
end

--[[
    Register change listener
    @param key string
    @param callback function(newValue, oldValue)
    @return function - Disconnect function
]]
function Variables:OnChanged(key, callback)
    if not _listeners[key] then
        _listeners[key] = {}
    end
    
    table.insert(_listeners[key], callback)
    
    -- Return disconnect function
    return function()
        local list = _listeners[key]
        if list then
            for i, cb in ipairs(list) do
                if cb == callback then
                    table.remove(list, i)
                    break
                end
            end
        end
    end
end

--[[
    Reset to defaults
]]
function Variables:Reset()
    for key, value in pairs(_defaults) do
        if key ~= "World" and key ~= "PlaceId" then
            self:Set(key, value)
        end
    end
end

--[[
    Get all state (readonly copy)
    @return table
]]
function Variables:GetAll()
    local copy = {}
    for k, v in pairs(_state) do
        copy[k] = v
    end
    return copy
end

--[[
    Debug print
]]
function Variables:Debug()
    print("=== VARIABLES STATE ===")
    for key, value in pairs(_state) do
        print(string.format("%s = %s", key, tostring(value)))
    end
    print("======================")
end

--// METATABLE MAGIC - Allow direct access
setmetatable(Variables, {
    __index = function(_, key)
        return _state[key]
    end,
    __newindex = function(_, key, value)
        Variables:Set(key, value)
    end
})

--// INITIALIZE
initializeDefaults()

return Variables