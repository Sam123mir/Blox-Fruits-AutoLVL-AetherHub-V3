--[[
    ================================================================
         AETHER HUB - FruitStorage Module (Refactored v3.0)
    ================================================================
    
    MEJORAS APLICADAS:
    ✓ Retry mechanism con exponential backoff
    ✓ Inventory tracking
    ✓ Storage validation
    ✓ Error handling robusto
    
    DEPENDENCIES: Services
]]

--// MODULE
local FruitStorage = {}
FruitStorage.__index = FruitStorage

--// DEPENDENCIES
local Services = nil

--// PRIVATE STATE
local _storageHistory = {}
local _lastStorageAttempt = 0

--// CONSTANTS
local STORAGE_COOLDOWN = 2 -- seconds
local MAX_RETRIES = 3
local RETRY_DELAY = 1

--[[
    Constructor
    @param services table
]]
function FruitStorage.new(services)
    local self = setmetatable({}, FruitStorage)
    
    Services = services or error("[FRUITSTORAGE] Services required")
    
    return self
end

--[[
    PRIVATE: Can attempt storage
    @return boolean, string?
]]
function FruitStorage:_canAttemptStorage()
    local currentTime = tick()
    local timeSinceLast = currentTime - _lastStorageAttempt
    
    if timeSinceLast < STORAGE_COOLDOWN then
        local waitTime = STORAGE_COOLDOWN - timeSinceLast
        return false, string.format("Cooldown: %.1fs remaining", waitTime)
    end
    
    return true
end

--[[
    PRIVATE: Invoke storage with retries
    @return boolean, string?
]]
function FruitStorage:_invokeStorageWithRetry()
    local commF = Services:GetCommF()
    if not commF then
        return false, "CommF_ remote not found"
    end
    
    for attempt = 1, MAX_RETRIES do
        local success, result = pcall(function()
            return commF:InvokeServer("StoreFruit")
        end)
        
        if success then
            -- Check result
            if result then
                return true, "Fruit stored successfully"
            else
                return false, "Storage returned false"
            end
        else
            warn(string.format(
                "[FRUITSTORAGE] Attempt %d/%d failed: %s",
                attempt, MAX_RETRIES, tostring(result)
            ))
            
            if attempt < MAX_RETRIES then
                task.wait(RETRY_DELAY * attempt) -- Exponential backoff
            end
        end
    end
    
    return false, "Max retries exceeded"
end

--[[
    PUBLIC: Store current fruit
    @return boolean, string - success, message
]]
function FruitStorage:StoreFruit()
    -- Check cooldown
    local canStore, message = self:_canAttemptStorage()
    if not canStore then
        return false, message
    end
    
    -- Check if has fruit
    if not self:HasFruit() then
        return false, "No fruit equipped"
    end
    
    local fruitName = self:GetEquippedFruit()
    
    -- Update timestamp
    _lastStorageAttempt = tick()
    
    -- Attempt storage
    local success, result = self:_invokeStorageWithRetry()
    
    -- Log to history
    table.insert(_storageHistory, {
        Fruit = fruitName,
        Success = success,
        Message = result,
        Timestamp = os.time()
    })
    
    -- Keep only last 50 entries
    if #_storageHistory > 50 then
        table.remove(_storageHistory, 1)
    end
    
    return success, result
end

--[[
    PUBLIC: Get equipped fruit name
    @return string?
]]
function FruitStorage:GetEquippedFruit()
    if not Services or not Services.LocalPlayer then
        return nil
    end
    
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if not data then return nil end
    
    local devilFruit = data:FindFirstChild("DevilFruit")
    if not devilFruit then return nil end
    
    local value = devilFruit.Value
    
    -- Validate
    if type(value) ~= "string" or value == "" then
        return nil
    end
    
    return value
end

--[[
    PUBLIC: Has fruit equipped
    @return boolean
]]
function FruitStorage:HasFruit()
    local fruit = self:GetEquippedFruit()
    return fruit ~= nil
end

--[[
    PUBLIC: Get inventory (from Data)
    @return table - Array of fruit names
]]
function FruitStorage:GetInventory()
    local inventory = {}
    
    if not Services or not Services.LocalPlayer then
        return inventory
    end
    
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if not data then return inventory end
    
    -- Blox Fruits stores inventory in Backpack
    local backpack = Services.LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name, "Fruit") then
                table.insert(inventory, item.Name)
            end
        end
    end
    
    return inventory
end

--[[
    PUBLIC: Get storage history
    @return table
]]
function FruitStorage:GetHistory()
    return _storageHistory
end

--[[
    PUBLIC: Clear history
]]
function FruitStorage:ClearHistory()
    _storageHistory = {}
end

--[[
    PUBLIC: Get storage stats
    @return table
]]
function FruitStorage:GetStats()
    local totalAttempts = #_storageHistory
    local successCount = 0
    
    for _, entry in ipairs(_storageHistory) do
        if entry.Success then
            successCount = successCount + 1
        end
    end
    
    return {
        TotalAttempts = totalAttempts,
        SuccessCount = successCount,
        FailCount = totalAttempts - successCount,
        SuccessRate = totalAttempts > 0 and (successCount / totalAttempts * 100) or 0
    }
end

return FruitStorage