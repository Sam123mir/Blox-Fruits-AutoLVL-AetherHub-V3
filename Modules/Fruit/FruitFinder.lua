--[[
    AETHER HUB - FruitFinder Module (v3.1 - Simplified)
    Detects Devil Fruits in the map
]]

local FruitFinder = {}

-- Dependencies
local Services = nil

-- State
local _onSpawnCallbacks = {}

-- Fruit containers
local CONTAINERS = {"Fruits", "AppleSpawner", "PineappleSpawner"}

-- Initialize
function FruitFinder.new(services)
    Services = services
    return FruitFinder
end

-- Check if is fruit
function FruitFinder:_isFruit(item)
    if not item:IsA("Tool") then return false end
    if not item:FindFirstChild("Handle") then return false end
    if not string.find(item.Name, "Fruit") then return false end
    return true
end

-- Get all fruits
function FruitFinder:GetAllFruits()
    local fruits = {}
    if not Services then return fruits end
    
    -- Check containers
    for _, containerName in ipairs(CONTAINERS) do
        local container = Services.Workspace:FindFirstChild(containerName)
        if container then
            for _, item in pairs(container:GetChildren()) do
                if self:_isFruit(item) then
                    table.insert(fruits, {
                        Name = item.Name,
                        Instance = item,
                        Position = item.Handle.Position
                    })
                end
            end
        end
    end
    
    -- Check workspace
    for _, item in pairs(Services.Workspace:GetChildren()) do
        if self:_isFruit(item) then
            table.insert(fruits, {
                Name = item.Name,
                Instance = item,
                Position = item.Handle.Position
            })
        end
    end
    
    return fruits
end

-- Get closest fruit
function FruitFinder:GetClosestFruit()
    local fruits = self:GetAllFruits()
    if #fruits == 0 then return nil end
    
    local hrp = Services:GetHumanoidRootPart()
    if not hrp then return fruits[1], nil end
    
    local closest = nil
    local closestDist = math.huge
    
    for _, fruit in ipairs(fruits) do
        local dist = (hrp.Position - fruit.Position).Magnitude
        if dist < closestDist then
            closest = fruit
            closestDist = dist
        end
    end
    
    return closest, closestDist
end

-- Has fruit
function FruitFinder:HasFruit()
    return #self:GetAllFruits() > 0
end

-- On fruit spawn
function FruitFinder:OnFruitSpawn(callback)
    table.insert(_onSpawnCallbacks, callback)
    return function()
        for i, cb in ipairs(_onSpawnCallbacks) do
            if cb == callback then
                table.remove(_onSpawnCallbacks, i)
                break
            end
        end
    end
end

return FruitFinder