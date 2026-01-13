--[[
    AETHER HUB - PROFESSIONAL VARIABLES SYSTEM v4.1
    ============================================================================
    Arquitectura orientada a Objetos (OOP) con patrones Observables y
    Inyección de Dependencias. Diseñado para alto rendimiento y escalabilidad.
    
    INGENIERÍA:
    - State Manager reactivo (Signals)
    - Type-Safe accessors (Luau Types)
    - Detección proactiva del entorno (Blox Fruits specialization)
    - Persistent Storage Manager (Auto-save/load)
]]

--// Type Definitions
export type VariableMetadata = {
    Category: string,
    Description: string?,
    IsPersistent: boolean,
    Validation: (any) -> (boolean, string?),
    LastUpdated: number
}

local Variables = {}
Variables.__index = Variables

--// Constants
local VALID_PLACE_IDS = {
    [2753915549] = "Sea 1",
    [4442272183] = "Sea 2",
    [7449423635] = "Sea 3"
}

--[[
    CONSTRUCTOR
    @param services table - Module Services
]]
function Variables.new(services)
    local self = setmetatable({}, Variables)
    
    self._services = services or error("[VARIABLES] Services required")
    self._storage = {} -- RAM Storage
    self._metadata = {} -- Metadata & Config
    self._signals = {} -- Observable signals
    self._connections = {} -- Signal connections
    
    -- Game State
    self.World = self:_detectWorld()
    self.IsInitialized = false
    
    -- Configuración
    self.Config = {
        SaveInterval = 60,
        DebugMode = false,
        FolderName = "AetherHub_Pro"
    }
    
    self:_initializeDefaultState()
    self:_loadFromDisk()
    
    print(string.format("[VARIABLES] Professional Module Initialized (World: %s)", self.World))
    
    return self
end

--[[
    PRIVATE: Detect current world based on PlaceId
]]
function Variables:_detectWorld(): string
    local placeId = game.PlaceId
    return VALID_PLACE_IDS[placeId] or "Unknown"
end

--[[
    PRIVATE: Initialize default script variables
]]
function Variables:_initializeDefaultState()
    -- Combat
    self:Register("FastAttack", false, {Category = "Combat", IsPersistent = true})
    self:Register("FastAttackMode", "Fast", {Category = "Combat", IsPersistent = true})
    self:Register("BringMob", false, {Category = "Combat", IsPersistent = true})
    self:Register("AutoFarmLevel", false, {Category = "Combat", IsPersistent = true})
    
    -- UI
    self:Register("Theme", "NeonDark", {Category = "UI", IsPersistent = true})
    self:Register("BypassTeleport", true, {Category = "Movement", IsPersistent = true})
    
    -- Fruit
    self:Register("AutoStoreFruit", true, {Category = "Fruit", IsPersistent = true})
    self:Register("FruitTeleport", false, {Category = "Fruit", IsPersistent = true})
    
    self.IsInitialized = true
end

--[[
    PUBLIC: Register a new variable with metadata
]]
function Variables:Register(key: string, initialValue: any, metadata: table)
    self._storage[key] = initialValue
    self._metadata[key] = {
        Category = metadata.Category or "Default",
        Description = metadata.Description,
        IsPersistent = metadata.IsPersistent or false,
        Validation = metadata.Validation,
        LastUpdated = os.time()
    }
    
    -- Create signal for observability
    if not self._signals[key] then
        self._signals[key] = {
            _listeners = {}
        }
    end
end

--[[
    PUBLIC: Set a variable value with validation
]]
function Variables:Set(key: string, value: any, silent: boolean?)
    local meta = self._metadata[key]
    
    -- Validation logic
    if meta and meta.Validation then
        local success, err = meta.Validation(value)
        if not success then
            warn(string.format("[VARIABLES] Validation failed for %s: %s", key, err or "Invalid value"))
            return false
        end
    end
    
    local oldValue = self._storage[key]
    if oldValue == value then return true end -- No change
    
    self._storage[key] = value
    if meta then meta.LastUpdated = os.time() end
    
    -- Notify listeners
    if not silent and self._signals[key] then
        for _, callback in ipairs(self._signals[key]._listeners) do
            task.spawn(callback, value, oldValue)
        end
    end
    
    return true
end

--[[
    PUBLIC: Get a variable value
]]
function Variables:Get(key: string, defaultValue: any?)
    local val = self._storage[key]
    if val ~= nil then
        return val
    end
    return defaultValue
end

--[[
    PUBLIC: Observe changes to a variable
    @param key string
    @param callback function(newValue, oldValue)
    @return connection table
]]
function Variables:Observe(key: string, callback: (any, any) -> ())
    if not self._signals[key] then
        self:Register(key, nil, {Category = "Dynamic"})
    end
    
    table.insert(self._signals[key]._listeners, callback)
    
    -- Return a "connection" object for easy cleanup
    local connection = {
        Disconnect = function()
            local listeners = self._signals[key]._listeners
            for i, c in ipairs(listeners) do
                if c == callback then
                    table.remove(listeners, i)
                    break
                end
            end
        end
    }
    
    return connection
end

--[[
    PRIVATE: Load persistent data from disk
]]
function Variables:_loadFromDisk()
    local success, result = pcall(function()
        local filePath = string.format("%s/config.json", self.Config.FolderName)
        if isfile and isfile(filePath) then
            local content = readfile(filePath)
            local data = self._services:GetHttpService():JSONDecode(content)
            
            for k, v in pairs(data) do
                if self._storage[k] ~= nil then
                    self:Set(k, v, true) -- Silent set
                end
            end
            return true
        end
        return false
    end)
    
    if success and result then
        print("[VARIABLES] persistent data loaded successfully")
    end
end

--[[
    PUBLIC: Save persistent data to disk
]]
function Variables:SaveToDisk()
    local success, result = pcall(function()
        local dataToSave = {}
        for k, v in pairs(self._storage) do
            local meta = self._metadata[k]
            if meta and meta.IsPersistent then
                dataToSave[k] = v
            end
        end
        
        if not isfolder(self.Config.FolderName) then
            makefolder(self.Config.FolderName)
        end
        
        local content = self._services:GetHttpService():JSONEncode(dataToSave)
        writefile(string.format("%s/config.json", self.Config.FolderName), content)
        return true
    end)
    
    return success, result
end

--[[
    PUBLIC: Clean up connections
]]
function Variables:Destroy()
    for _, signal in pairs(self._signals) do
        table.clear(signal._listeners)
    end
    table.clear(self._signals)
    table.clear(self._storage)
    table.clear(self._metadata)
end

-- Singleton pattern
local singletonInstance = nil

function Variables.GetSingleton(services)
    if not singletonInstance then
        singletonInstance = Variables.new(services)
    end
    return singletonInstance
end

return Variables.GetSingleton