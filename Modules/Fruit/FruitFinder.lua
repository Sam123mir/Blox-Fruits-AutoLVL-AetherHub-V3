--[[
    ================================================================
         AETHER HUB - FruitFinder Module (Refactored v3.0)
    ================================================================
    
    MEJORAS APLICADAS:
    ✓ Real-time fruit spawn detection
    ✓ Priority system (by rarity)
    ✓ Event-driven notifications
    ✓ Multi-container support
    ✓ Performance caching
    
    DEPENDENCIES: Services
]]

--// MODULE
local FruitFinder = {}
FruitFinder.__index = FruitFinder

--// DEPENDENCIES
local Services = nil

--// PRIVATE STATE
local _fruitCache = {}
local _lastScanTime = 0
local _connections = {}
local _onFruitSpawnCallbacks = {}

--// CONSTANTS
local CACHE_LIFETIME = 2 -- seconds
local FRUIT_CONTAINERS = {
    "Fruits",
    "AppleSpawner",
    "PineappleSpawner",
    "BananaSpawner"
}

-- Fruit rarity system (higher = rarer)
local FRUIT_RARITY = {
    -- COMMON (Comunes)
    ["Rocket Fruit"] = 1,
    ["Spin Fruit"] = 1,
    ["Blade Fruit"] = 1,
    ["Spring Fruit"] = 1,
    ["Bomb Fruit"] = 1,
    ["Spike Fruit"] = 1,
    ["Smoke Fruit"] = 1,

    -- UNCOMMON (Poco Comunes)
    ["Flame Fruit"] = 2,
    ["Falcon Fruit"] = 2,
    ["Ice Fruit"] = 2,
    ["Sand Fruit"] = 2,
    ["Dark Fruit"] = 2,
    ["Diamond Fruit"] = 2,

    -- RARE (Raras)
    ["Light Fruit"] = 3,
    ["Rubber Fruit"] = 3,
    ["Ghost Fruit"] = 3,
    ["Magma Fruit"] = 3,
    ["Barrier Fruit"] = 3,

    -- LEGENDARY (Legendarias)
    ["Quake Fruit"] = 4,
    ["Buddha Fruit"] = 4,
    ["Love Fruit"] = 4,
    ["Spider Fruit"] = 4,
    ["Sound Fruit"] = 4,
    ["Phoenix Fruit"] = 4,
    ["Portal Fruit"] = 4,
    ["Rumble Fruit"] = 4,
    ["Pain Fruit"] = 4,
    ["Blizzard Fruit"] = 4,

    -- MYTHICAL (Míticas)
    ["Gravity Fruit"] = 5,
    ["Mammoth Fruit"] = 5,
    ["T-Rex Fruit"] = 5,
    ["Dough Fruit"] = 5,
    ["Shadow Fruit"] = 5,
    ["Venom Fruit"] = 5,
    ["Control Fruit"] = 5,
    ["Spirit Fruit"] = 5,
    ["Dragon Fruit"] = 5,
    ["Leopard Fruit"] = 5,
    ["Kitsune Fruit"] = 5,
    ["Gas Fruit"] = 5,
    ["Yeti Fruit"] = 5
}
--[[
    Constructor
    @param services table
]]
function FruitFinder.new(services)
    local self = setmetatable({}, FruitFinder)
    
    Services = services or error("[FRUITFINDER] Services required")
    
    -- Setup fruit spawn listeners
    self:_setupSpawnListeners()
    
    return self
end

--[[
    PRIVATE: Setup spawn listeners
]]
function FruitFinder:_setupSpawnListeners()
    -- Listen to workspace children added
    local connection = Services.Workspace.ChildAdded:Connect(function(child)
        task.wait(0.1) -- Small delay for properties to load
        
        if self:_isFruit(child) then
            self:_onFruitDetected(child)
        end
    end)
    
    table.insert(_connections, connection)
    
    -- Listen to container children
    for _, containerName in ipairs(FRUIT_CONTAINERS) do
        local container = Services.Workspace:FindFirstChild(containerName)
        if container then
            local conn = container.ChildAdded:Connect(function(child)
                task.wait(0.1)
                if self:_isFruit(child) then
                    self:_onFruitDetected(child)
                end
            end)
            table.insert(_connections, conn)
        end
    end
end

--[[
    PRIVATE: Check if instance is a fruit
    @param instance Instance
    @return boolean
]]
function FruitFinder:_isFruit(instance)
    if not instance or not instance:IsA("Tool") then
        return false
    end
    
    -- Check for "Fruit" in name
    if not string.find(instance.Name, "Fruit") then
        return false
    end
    
    -- Must have Handle
    local handle = instance:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then
        return false
    end
    
    return true
end

--[[
    PRIVATE: On fruit detected
    @param fruit Tool
]]
function FruitFinder:_onFruitDetected(fruit)
    print(string.format("[FRUITFINDER] Detected: %s", fruit.Name))
    
    -- Invalidate cache
    _lastScanTime = 0
    
    -- Notify callbacks
    for _, callback in ipairs(_onFruitSpawnCallbacks) do
        task.spawn(callback, fruit)
    end
end

--[[
    PRIVATE: Get fruit rarity
    @param fruitName string
    @return number
]]
function FruitFinder:_getFruitRarity(fruitName)
    return FRUIT_RARITY[fruitName] or 0
end

--[[
    PRIVATE: Scan for fruits
]]
function FruitFinder:_scanFruits()
    local currentTime = tick()
    
    -- Use cache if valid
    if currentTime - _lastScanTime < CACHE_LIFETIME then
        return _fruitCache
    end
    
    _fruitCache = {}
    
    -- Scan containers
    for _, containerName in ipairs(FRUIT_CONTAINERS) do
        local container = Services.Workspace:FindFirstChild(containerName)
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if self:_isFruit(item) then
                    self:_addFruitToCache(item)
                end
            end
        end
    end
    
    -- Scan workspace root
    for _, item in ipairs(Services.Workspace:GetChildren()) do
        if self:_isFruit(item) then
            self:_addFruitToCache(item)
        end
    end
    
    _lastScanTime = currentTime
    return _fruitCache
end

--[[
    PRIVATE: Add fruit to cache
    @param fruit Tool
]]
function FruitFinder:_addFruitToCache(fruit)
    local handle = fruit:FindFirstChild("Handle")
    if not handle then return end
    
    table.insert(_fruitCache, {
        Name = fruit.Name,
        Instance = fruit,
        Position = handle.Position,
        Rarity = self:_getFruitRarity(fruit.Name),
        FoundAt = tick()
    })
end

--[[
    PUBLIC: Get all fruits
    @return table - Array of fruit data
]]
function FruitFinder:GetAllFruits()
    return self:_scanFruits()
end

--[[
    PUBLIC: Get closest fruit
    @return table?, number? - fruitData, distance
]]
function FruitFinder:GetClosestFruit()
    local fruits = self:GetAllFruits()
    if #fruits == 0 then return nil end
    
    local playerHRP = Services:GetHumanoidRootPart()
    if not playerHRP then
        -- Return first fruit if no player position
        return fruits[1], nil
    end
    
    local closest = nil
    local closestDist = math.huge
    
    for _, fruit in ipairs(fruits) do
        local distance = (playerHRP.Position - fruit.Position).Magnitude
        if distance < closestDist then
            closest = fruit
            closestDist = distance
        end
    end
    
    return closest, closestDist
end

--[[
    PUBLIC: Get rarest fruit
    @return table? - fruitData
]]
function FruitFinder:GetRarestFruit()
    local fruits = self:GetAllFruits()
    if #fruits == 0 then return nil end
    
    -- Sort by rarity (highest first)
    table.sort(fruits, function(a, b)
        return a.Rarity > b.Rarity
    end)
    
    return fruits[1]
end

--[[
    PUBLIC: Has fruit in map
    @return boolean
]]
function FruitFinder:HasFruit()
    return #self:GetAllFruits() > 0
end

--[[
    PUBLIC: Register spawn callback
    @param callback function(fruit)
    @return function - Disconnect
]]
function FruitFinder:OnFruitSpawn(callback)
    table.insert(_onFruitSpawnCallbacks, callback)
    
    -- Return disconnect function
    return function()
        for i, cb in ipairs(_onFruitSpawnCallbacks) do
            if cb == callback then
                table.remove(_onFruitSpawnCallbacks, i)
                break
            end
        end
    end
end

--[[
    PUBLIC: Clear cache
]]
function FruitFinder:ClearCache()
    _fruitCache = {}
    _lastScanTime = 0
end

--[[
    PUBLIC: Destroy
]]
function FruitFinder:Destroy()
    for _, connection in pairs(_connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    _connections = {}
    _fruitCache = {}
    _onFruitSpawnCallbacks = {}
end

return FruitFinder