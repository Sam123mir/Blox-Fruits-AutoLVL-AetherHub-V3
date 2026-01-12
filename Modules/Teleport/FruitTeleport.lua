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
    
    DEPENDENCIES: Services, Variables, Teleporter, FruitFinder, FruitStorage
]]

--// MODULE
local FruitTeleport = {}
FruitTeleport.__index = FruitTeleport

--// DEPENDENCIES
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

--// CONSTANTS
local TELEPORT_COOLDOWN = 3 -- seconds between teleports
local PICKUP_DELAY = 0.5 -- time to wait after teleporting to pick up fruit
local SCAN_INTERVAL = 2 -- seconds between scans

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
    PRIVATE: On fruit detected
    @param fruit Instance
]]
function FruitTeleport:_onFruitDetected(fruit)
    if not _running or not Variables:Get("FruitTeleport") then
        return
    end
    
    -- Add to queue
    local rarity = FruitFinder:_getFruitRarity(fruit.Name) or 0
    table.insert(_fruitQueue, {
        Fruit = fruit,
        Rarity = rarity,
        DetectedAt = tick()
    })
    
    -- Sort queue by rarity (highest first)
    table.sort(_fruitQueue, function(a, b)
        return a.Rarity > b.Rarity
    end)
    
    -- Notify callbacks
    self:_notifyFruitFound(fruit)
    
    -- Process queue
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
        return
    end
    
    -- Get highest priority fruit
    local entry = table.remove(_fruitQueue, 1)
    if not entry or not entry.Fruit or not entry.Fruit.Parent then
        return -- Fruit no longer exists
    end
    
    -- Teleport to fruit
    Teleporter:TeleportToInstance(entry.Fruit)
    _lastTeleportTime = tick()
    
    print(string.format("[FRUITTELEPORT] Teleported to: %s (Rarity: %d)", 
        entry.Fruit.Name, entry.Rarity))
    
    -- Auto store if enabled
    if Variables:Get("FruitAutoStore") and FruitStorage then
        task.delay(PICKUP_DELAY, function()
            local success, message = FruitStorage:StoreFruit()
            if success then
                print("[FRUITTELEPORT] Fruit stored automatically")
            end
        end)
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
    
    -- Notify callbacks
    for _, callback in ipairs(_onFruitFoundCallbacks) do
        task.spawn(callback, fruit.Name, distance)
    end
    
    -- Teleport
    Teleporter:TeleportToInstance(fruit.Instance)
    _lastTeleportTime = tick()
    
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
                local fruit = FruitFinder:GetClosestFruit()
                if fruit then
                    self:_onFruitDetected(fruit.Instance)
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
end

return FruitTeleport
