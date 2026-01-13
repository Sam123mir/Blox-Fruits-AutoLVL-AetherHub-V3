--[[
    AETHER HUB - PROFESSIONAL SERVICES SYSTEM v4.1
    ============================================================================
    Capa de abstracción de servicios de Roblox diseñada para robustez absoluta,
    prevención de memory leaks y gestión eficiente de recursos.
    
    INGENIERÍA:
    - Lazy Loading con caché de primer nivel
    - Safe Remote Invocation (CommF wrapper con reintentos)
    - Character State Management robusto
    - Automated Connection Tracking & Cleanup
]]

local Services = {}
Services.__index = Services

--// Constants
local MAX_RETRIES = 3
local RETRY_DELAY = 0.5

--[[
    CONSTRUCTOR
]]
function Services.new()
    local self = setmetatable({}, Services)
    
    -- Local References
    self.LocalPlayer = game:GetService("Players").LocalPlayer
    
    -- Internal State
    self._cache = {} -- Service cache
    self._connections = {} -- Registered connections for cleanup
    self._remotesCache = {} -- Remote objects cache
    
    print("[SERVICES] Professional Module Initialized")
    
    return self
end

--[[
    PUBLIC: Get any Roblox service with lazy loading
]]
function Services:GetService(name: string)
    if self._cache[name] then
        return self._cache[name]
    end
    
    local success, service = pcall(function()
        return game:GetService(name)
    end)
    
    if success and service then
        self._cache[name] = service
        return service
    end
    
    warn(string.format("[SERVICES] Failed to get service: %s", name))
    return nil
end

--[[
    PUBLIC: Robust Character Getter
    Handles cases where character might be nil or loading
]]
function Services:GetCharacter()
    local character = self.LocalPlayer.Character
    if character then return character end
    
    -- Soft wait
    local success, char = pcall(function()
        return self.LocalPlayer.CharacterAdded:Wait()
    end)
    
    return success and char or nil
end

--[[
    PUBLIC: Get HumanoidRootPart safely
]]
function Services:GetHumanoidRootPart()
    local character = self:GetCharacter()
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

--[[
    PUBLIC: Safe Remote Invocation (Blox Fruits CommF Style)
    Includes retries and type validation
]]
function Services:InvokeCommF(methodName: string, ...)
    local args = {...}
    local remotes = self:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if not remotes then return false, "Remotes folder not found" end
    
    local commF = remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF")
    if not commF then return false, "CommF remote not found" end
    
    for attempt = 1, MAX_RETRIES do
        local success, result = pcall(function()
            if commF:IsA("RemoteFunction") then
                return commF:InvokeServer(methodName, unpack(args))
            else
                commF:FireServer(methodName, unpack(args))
                return true
            end
        end)
        
        if success then
            return true, result
        end
        
        task.wait(RETRY_DELAY * attempt)
    end
    
    return false, "Max retries exceeded"
end

--[[
    PUBLIC: Register a connection for automatic cleanup
]]
function Services:RegisterConnection(connection)
    if connection then
        table.insert(self._connections, connection)
    end
    return connection
end

--[[
    PUBLIC: Disconnect all registered connections
]]
function Services:DisconnectAll()
    local count = 0
    for _, connection in ipairs(self._connections) do
        if connection.Connected then
            connection:Disconnect()
            count += 1
        end
    end
    table.clear(self._connections)
    return count
end

--[[
    PUBLIC: Helper to get common services quickly
]]
function Services:GetHttpService() return self:GetService("HttpService") end
Services.HttpService = game:GetService("HttpService") -- Static reference for compatibility

-- Singleton pattern
local singletonInstance = nil

function Services.GetSingleton()
    if not singletonInstance then
        singletonInstance = Services.new()
    end
    return singletonInstance
end

return Services.GetSingleton