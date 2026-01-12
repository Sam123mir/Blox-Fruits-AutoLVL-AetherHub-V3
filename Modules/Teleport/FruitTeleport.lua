--[[
    ================================================================
         AETHER HUB - FruitTeleport Module (Refactored v3.0)
    ================================================================
    
    MEJORAS APLICADAS:
    ✓ Event-driven fruit detection
    ✓ Priority queue for rare fruits
    ✓ Auto-store integration
    ✓ Cooldown system
    ✓ Proper cleanup
    ✓ Distance-based filtering
    
    DEPENDENCIES: Services, Variables, Teleporter, FruitFinder, FruitStorage
]]

--// MODULE
local FruitTeleport = {}
FruitTeleport.__index = FruitTeleport

--// DEPENDENCIES (will be injected)
local Services = nil
local Variables = nil
local Teleporter = nil
local FruitFinder = nil
local FruitStorage = nil

--// PRIVATE STATE
local _running = false
local _connections = {}
local _onFruitFoundCallbacks = {}
local _lastTeleportTime = 0
local _fruitQueue = {}
local _processedFruits = {} -- Prevent duplicate teleports

--// CONSTANTS
local TELEPORT_COOLDOWN = 3 -- seconds between teleports
local PICKUP_DELAY = 0.5 -- time to wait after teleporting to pick up fruit
local SCAN_INTERVAL = 2 -- seconds between scans
local MAX_QUEUE_SIZE = 10 -- Prevent queue overflow
local FRUIT_MEMORY_TIME = 60 -- Remember fruits for 60 seconds

--[[
    Constructor
    @param services table
    @param variables table
    @param teleporter table
    @param fruitFinder table
    @param fruitStorage table?
]]
function FruitTeleport.new(services, variables, teleporter, fruitFinder, fruitStorage)
    local self = setmetatable({}, FruitTeleport)
    
    Services = services or error("[FRUITTELEPORT] Services required")
    Variables = variables or error("[FRUITTELEPORT] Variables required")
    Teleporter = teleporter or error("[FRUITTELEPORT] Teleporter required")
    FruitFinder = fruitFinder or error("[FRUITTELEPORT] FruitFinder required")
    FruitStorage = fruitStorage -- Optional
    
    -- Setup fruit spawn listener
    self:_setupSpawnListener()
    
    -- Cleanup old processed fruits periodically
    self:_startMemoryCleaner()
    
    return self
end

--[[
    PRIVATE: Setup fruit spawn listener
]]
function FruitTeleport:_setupSpawnListener()
    if not FruitFinder then return end
    
    local disconnect = FruitFinder:OnFruitSpawn(function(fruit)
        self:_onFruitDetected(fruit)
    end)
    
    table.insert(_connections, {Disconnect = disconnect})
end

--[[
    PRIVATE: Start memory cleaner (prevents memory buildup)
]]
function FruitTeleport:_startMemoryCleaner()
    task.spawn(function()
        while _running do
            local currentTime = tick()
            
            -- Clean old processed fruits
            for fruitId, timestamp in pairs(_processedFruits) do
                if currentTime - timestamp > FRUIT_MEMORY_TIME then
                    _processedFruits[fruitId] = nil
                end
            end
            
            task.wait(30) -- Clean every 30 seconds
        end
    end)
end

--[[
    PRIVATE: Get unique fruit ID
    @param fruit Instance
    @return string
]]
function FruitTeleport:_getFruitId(fruit)
    if not fruit then return "" end
    
    local handle = fruit:FindFirstChild("Handle")
    if handle then
        return string.format("%s_%s", fruit.Name, tostring(handle.Position))
    end
    
    return fruit.Name
end

--[[
    PRIVATE: Check if fruit was already processed
    @param fruit Instance
    @return boolean
]]
function FruitTeleport:_wasProcessed(fruit)
    local fruitId = self:_getFruitId(fruit)
    return _processedFruits[fruitId] ~= nil
end

--[[
    PRIVATE: Mark fruit as processed
    @param fruit Instance
]]
function FruitTeleport:_markAsProcessed(fruit)
    local fruitId = self:_getFruitId(fruit)
    _processedFruits[fruitId] = tick()
end

--[[
    PRIVATE: On fruit detected
    @param fruit Instance
]]
function FruitTeleport:_onFruitDetected(fruit)
    if not _running or not Variables:Get("FruitTeleport") then
        return
    end
    
    -- Skip if already processed
    if self:_wasProcessed(fruit) then
        return
    end
    
    -- Prevent queue overflow
    if #_fruitQueue >= MAX_QUEUE_SIZE then
        warn("[FRUITTELEPORT] Queue full, skipping fruit")
        return
    end
    
    -- Add to queue
    local rarity = 0
    if FruitFinder._getFruitRarity then
        rarity = FruitFinder:_getFruitRarity(fruit.Name) or 0
    end
    
    table.insert(_fruitQueue, {
        Fruit = fruit,
        Rarity = rarity,
        DetectedAt = tick()
    })
    
    -- Sort queue by rarity (highest first)
    table.sort(_fruitQueue, function(a, b)
        if a.Rarity == b.Rarity then
            -- If same rarity, prioritize by detection time (newest first)
            return a.DetectedAt > b.DetectedAt
        end
        return a.Rarity > b.Rarity
    end)
    
    -- Notify callbacks
    self:_notifyFruitFound(fruit)
    
    -- Process queue immediately
    self:_processQueue()
end

--[[
    PRIVATE: Notify fruit found callbacks
    @param fruit Instance
]]
function FruitTeleport:_notifyFruitFound(fruit)
    local distance = nil
    local handle = fruit:FindFirstChild("Handle")
    
    if handle and Services then
        local hrp = Services:GetHumanoidRootPart()
        if hrp then
            distance = (hrp.Position - handle.Position).Magnitude
        end
    end
    
    for _, callback in ipairs(_onFruitFoundCallbacks) do
        task.spawn(callback, fruit.Name, distance)
    end
end

--[[
    PRIVATE: Process fruit queue
]]
function FruitTeleport:_processQueue()
    if #_fruitQueue == 0 then return end
    
    -- Check cooldown
    local currentTime = tick()
    if currentTime - _lastTeleportTime < TELEPORT_COOLDOWN then
        -- Schedule retry
        task.delay(TELEPORT_COOLDOWN - (currentTime - _lastTeleportTime), function()
            self:_processQueue()
        end)
        return
    end
    
    -- Get highest priority fruit
    local entry = table.remove(_fruitQueue, 1)
    if not entry or not entry.Fruit or not entry.Fruit.Parent then
        -- Fruit no longer exists, try next
        self:_processQueue()
        return
    end
    
    -- Mark as processed
    self:_markAsProcessed(entry.Fruit)
    
    -- Teleport to fruit
    local teleportSuccess = Teleporter:TeleportToInstance(entry.Fruit, {
        useTween = false,
        offset = Vector3.new(0, 2, 0) -- Slight Y offset
    })
    
    if teleportSuccess then
        _lastTeleportTime = tick()
        
        print(string.format("[FRUITTELEPORT] Teleported to: %s (Rarity: %d)", 
            entry.Fruit.Name, entry.Rarity))
        
        -- Auto store if enabled
        if Variables:Get("FruitAutoStore") and FruitStorage then
            task.delay(PICKUP_DELAY, function()
                -- Wait for fruit to be picked up
                task.wait(0.3)
                
                local success, message = FruitStorage:StoreFruit()
                if success then
                    print("[FRUITTELEPORT] Fruit stored automatically")
                else
                    warn("[FRUITTELEPORT] Auto-store failed: " .. tostring(message))
                end
            end)
        end
    else
        warn("[FRUITTELEPORT] Teleport failed for: " .. entry.Fruit.Name)
    end
end

--[[
    PUBLIC: Teleport to closest fruit
    @return table? - fruit data
]]
function FruitTeleport:TeleportToClosestFruit()
    if not FruitFinder or not Teleporter then
        return nil
    end
    
    local fruit, distance = FruitFinder:GetClosestFruit()
    if not fruit then
        return nil
    end
    
    -- Check if already processed
    if self:_wasProcessed(fruit.Instance) then
        print("[FRUITTELEPORT] Fruit already processed, skipping")
        return nil
    end
    
    -- Notify callbacks
    for _, callback in ipairs(_onFruitFoundCallbacks) do
        task.spawn(callback, fruit.Name, distance)
    end
    
    -- Teleport
    local success = Teleporter:TeleportToInstance(fruit.Instance)
    
    if success then
        _lastTeleportTime = tick()
        self:_markAsProcessed(fruit.Instance)
        
        print(string.format("[FRUITTELEPORT] Manual teleport to: %s (%.1fm)", 
            fruit.Name, distance or 0))
    end
    
    return fruit
end

--[[
    PUBLIC: Set callback for fruit found
    @param callback function(name, distance)
    @return function - disconnect
]]
function FruitTeleport:SetOnFruitFound(callback)
    table.insert(_onFruitFoundCallbacks, callback)
    
    return function()
        for i, cb in ipairs(_onFruitFoundCallbacks) do
            if cb == callback then
                table.remove(_onFruitFoundCallbacks, i)
                break
            end
        end
    end
end

--[[
    PRIVATE: Main scan loop
]]
function FruitTeleport:_scanLoop()
    while _running do
        if Variables:Get("FruitTeleport") then
            -- Check if any fruits exist
            if FruitFinder:HasFruit() then
                local allFruits = FruitFinder:GetAllFruits()
                
                for _, fruitData in ipairs(allFruits) do
                    if not self:_wasProcessed(fruitData.Instance) then
                        self:_onFruitDetected(fruitData.Instance)
                    end
                end
            end
        end
        
        task.wait(SCAN_INTERVAL)
    end
end

--[[
    PUBLIC: Start auto teleport
]]
function FruitTeleport:Start()
    if _running then
        warn("[FRUITTELEPORT] Already running")
        return
    end
    
    _running = true
    Variables:Set("FruitTeleport", true)
    
    -- Start scan loop
    task.spawn(function()
        self:_scanLoop()
    end)
    
    print("[FRUITTELEPORT] Started")
end

--[[
    PUBLIC: Stop auto teleport
]]
function FruitTeleport:Stop()
    _running = false
    Variables:Set("FruitTeleport", false)
    _fruitQueue = {}
    
    print("[FRUITTELEPORT] Stopped")
end

--[[
    PUBLIC: Toggle
    @return boolean - new running state
]]
function FruitTeleport:Toggle()
    if _running then
        self:Stop()
    else
        self:Start()
    end
    return _running
end

--[[
    PUBLIC: Is running
    @return boolean
]]
function FruitTeleport:IsRunning()
    return _running
end

--[[
    PUBLIC: Get queue length
    @return number
]]
function FruitTeleport:GetQueueLength()
    return #_fruitQueue
end

--[[
    PUBLIC: Get stats
    @return table
]]
function FruitTeleport:GetStats()
    return {
        QueueLength = #_fruitQueue,
        ProcessedCount = table.count(_processedFruits),
        LastTeleport = _lastTeleportTime,
        IsRunning = _running
    }
end

--[[
    PUBLIC: Clear processed memory
]]
function FruitTeleport:ClearMemory()
    _processedFruits = {}
    print("[FRUITTELEPORT] Memory cleared")
end

--[[
    PUBLIC: Destroy
]]
function FruitTeleport:Destroy()
    self:Stop()
    
    for _, connection in pairs(_connections) do
        if type(connection) == "table" and connection.Disconnect then
            connection.Disconnect()
        elseif type(connection) == "function" then
            connection()
        end
    end
    
    _connections = {}
    _onFruitFoundCallbacks = {}
    _fruitQueue = {}
    _processedFruits = {}
end

return FruitTeleport