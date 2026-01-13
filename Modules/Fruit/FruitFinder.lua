--[[
    AETHER HUB - ENTERPRISE FRUIT FINDER v5.2
    ============================================================================
    Detección y gestión de Devil Fruits con alta precisión.
]]

local FruitFinder = {}
FruitFinder.__index = FruitFinder

--// Constants
local CONTAINERS = {"Fruits", "AppleSpawner", "PineappleSpawner"}

function FruitFinder.new(services, variables)
    local self = setmetatable({}, FruitFinder)
    
    self._services = services or error("[FRUITFINDER] Services required")
    self._vars = variables or error("[FRUITFINDER] Variables required")
    
    print("[FRUIT] Enterprise Module Initialized")
    return self
end

function FruitFinder:_isFruit(item: Instance)
    return item:IsA("Tool") and item:FindFirstChild("Handle") and item.Name:find("Fruit")
end

function FruitFinder:GetAllFruits()
    local fruits = {}
    
    local function check(parent)
        if not parent then return end
        for _, item in ipairs(parent:GetChildren()) do
            if self:_isFruit(item) then
                table.insert(fruits, {
                    Instance = item,
                    Name = item.Name,
                    Position = item.Handle.Position
                })
            end
        end
    end

    for _, name in ipairs(CONTAINERS) do
        check(workspace:FindFirstChild(name))
    end
    check(workspace)
    
    return fruits
end

function FruitFinder:GetClosestFruit()
    local fruits = self:GetAllFruits()
    local hrp = self._services:GetHumanoidRootPart()
    if #fruits == 0 or not hrp then return nil end
    
    local closest, minCDist = nil, math.huge
    for _, fruit in ipairs(fruits) do
        local dist = (hrp.Position - fruit.Position).Magnitude
        if dist < minCDist then
            closest = fruit
            minCDist = dist
        end
    end
    return closest
end

return FruitFinder