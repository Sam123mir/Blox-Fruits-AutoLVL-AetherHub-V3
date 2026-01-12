--[[
    AETHER HUB - Services Module (v3.3 - Professional Refactor)
    Optimized for performance, safety, and scalability
]]

-- Type checking utilities
local TypeChecker = {
    SafeWait = function(timeout)
        return task.wait(timeout or 0.03) -- Better than wait()
    end,

    AssertType = function(value, expectedType, paramName)
        if type(value) ~= expectedType then
            error(string.format("%s must be %s, got %s", 
                paramName, expectedType, type(value)), 3)
        end
        return true
    end,

    IsValidInstance = function(instance, className)
        if not instance or not instance:IsA("Instance") then
            return false
        end
        if className and not instance:IsA(className) then
            return false
        end
        return true
    end
}

-- Main Services module using OOP pattern
local Services = {}
Services.__index = Services

-- Private cache for performance
local _cache = {
    Remotes = nil,
    CommF = nil,
    LastRemotesCheck = 0,
    CacheTTL = 5 -- seconds
}

--[[
    Service Initialization
    Using lazy loading pattern for performance
]]
function Services.new()
    local self = setmetatable({}, Services)
    
    -- Core services (loaded once)
    self.Players = game:GetService("Players")
    self.ReplicatedStorage = game:GetService("ReplicatedStorage")
    self.Workspace = game:GetService("Workspace")
    self.TweenService = game:GetService("TweenService")
    self.UserInputService = game:GetService("UserInputService")
    self.RunService = game:GetService("RunService")
    self.HttpService = game:GetService("HttpService")
    self.MarketplaceService = game:GetService("MarketplaceService")
    
    -- Player references with validation
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        warn("[Services] LocalPlayer not found - running in server context?")
    end
    
    -- Connection cleanup
    self._connections = {}
    
    return self
end

--[[
    Character Management with robust error handling
    Uses task-based async patterns
]]
function Services:GetCharacter()
    TypeChecker.AssertType(self, "table", "self")
    
    if not self.LocalPlayer then
        return nil
    end
    
    -- Return existing character immediately
    local character = self.LocalPlayer.Character
    if character and character:IsA("Model") then
        return character
    end
    
    -- Wait for character with timeout
    local success, result = pcall(function()
        local charEvent = self.LocalPlayer.CharacterAdded
        local timeout = 10 -- seconds
        local startTime = os.clock()
        
        while os.clock() - startTime < timeout do
            character = self.LocalPlayer.Character
            if character and character:IsA("Model") then
                return character
            end
            charEvent:Wait()
        end
        
        error("Character loading timeout after " .. timeout .. " seconds")
    end)
    
    return success and result or nil
end

function Services:GetHumanoidRootPart()
    local character = self:GetCharacter()
    if not character then return nil end
    
    local hrp = character:WaitForChild("HumanoidRootPart", 2)
    if hrp and hrp:IsA("BasePart") then
        return hrp
    end
    
    return nil
end

function Services:GetHumanoid()
    local character = self:GetCharacter()
    if not character then return nil end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid:IsA("Humanoid") then
        return humanoid
    end
    
    return nil
end

--[[
    Remote Service with intelligent caching
    Prevents repetitive FindFirstChild calls
]]
function Services:GetRemotes(forceRefresh)
    if not forceRefresh and _cache.Remotes and 
       (os.clock() - _cache.LastRemotesCheck < _cache.CacheTTL) then
        return _cache.Remotes
    end
    
    local remotes = self.ReplicatedStorage:FindFirstChild("Remotes")
    _cache.Remotes = remotes
    _cache.LastRemotesCheck = os.clock()
    
    return remotes
end

function Services:GetCommF(forceRefresh)
    if not forceRefresh and _cache.CommF and 
       (os.clock() - _cache.LastRemotesCheck < _cache.CacheTTL) then
        return _cache.CommF
    end
    
    local remotes = self:GetRemotes()
    if not remotes then
        _cache.CommF = nil
        return nil
    end
    
    -- Try multiple possible names for CommF
    local possibleNames = {"CommF_", "CommF", "CommunicationF", "RemoteFunction"}
    local commF = nil
    
    for _, name in ipairs(possibleNames) do
        commF = remotes:FindFirstChild(name)
        if commF and (commF:IsA("RemoteFunction") or commF:IsA("RemoteEvent")) then
            break
        end
    end
    
    _cache.CommF = commF
    return commF
end

--[[
    Safe Remote Invocation with comprehensive error handling
    Includes retry logic and validation
]]
function Services:InvokeCommF(methodName, ...)
    TypeChecker.AssertType(methodName, "string", "methodName")
    
    local maxRetries = 3
    local retryDelay = 0.5
    
    for attempt = 1, maxRetries do
        local commF = self:GetCommF(attempt == 1) -- Refresh cache on first attempt
        
        if not commF then
            -- Try to find CommF in alternative locations
            local alternativePaths = {
                self.ReplicatedStorage,
                self.Workspace,
                game:GetService("Lighting")
            }
            
            for _, location in ipairs(alternativePaths) do
                commF = location:FindFirstChild("CommF_") or 
                       location:FindFirstChild("CommF")
                if commF then
                    _cache.CommF = commF
                    break
                end
            end
            
            if not commF then
                task.wait(retryDelay)
                if attempt == maxRetries then
                    return false, "CommF_ not found in any expected location"
                end
                continue
            end
        end
        
        -- Validate remote type
        if not (commF:IsA("RemoteFunction") or commF:IsA("RemoteEvent")) then
            return false, "CommF_ is not a valid RemoteFunction/RemoteEvent"
        end
        
        -- Safe invocation
        local args = {...}
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
        elseif attempt < maxRetries then
            -- Clear cache on failure
            _cache.CommF = nil
            _cache.Remotes = nil
            task.wait(retryDelay * attempt) -- Exponential backoff
        else
            return false, "Invocation failed: " .. tostring(result)
        end
    end
    
    return false, "Max retries exceeded"
end

--[[
    Memory leak prevention
]]
function Services:DisconnectAll()
    for _, connection in ipairs(self._connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(self._connections)
end

function Services:RegisterConnection(connection)
    if connection and connection.Connected then
        table.insert(self._connections, connection)
    end
    return connection
end

-- Auto-cleanup on module destruction
local function cleanup()
    if Services.__instance then
        Services.__instance:DisconnectAll()
    end
end

-- Singleton pattern with lazy initialization
function Services.GetSingleton()
    if not Services.__instance then
        Services.__instance = Services.new()
        game:GetService("Players").PlayerRemoving:Connect(cleanup)
    end
    return Services.__instance
end

return Services.GetSingleton()