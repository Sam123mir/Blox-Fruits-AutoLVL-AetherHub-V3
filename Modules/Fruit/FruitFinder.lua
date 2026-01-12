--[[
    AETHER HUB - Fruit Finder Module
    Detects Devil Fruits in the map
    Requires: Services (passed via init)
]]

local FruitFinder = {}
FruitFinder.Services = nil

-- Initialize with dependencies
function FruitFinder:Init(services)
    self.Services = services
    return self
end

-- Fruit spawn locations
local FRUIT_CONTAINERS = {"Fruits", "AppleSpawner", "PineappleSpawner"}

-- Find all Devil Fruits in the map
function FruitFinder:GetAllFruits()
    local fruits = {}
    if not self.Services then return fruits end
    
    -- Check containers
    for _, containerName in ipairs(FRUIT_CONTAINERS) do
        local container = self.Services.Workspace:FindFirstChild(containerName)
        if container then
            for _, item in pairs(container:GetChildren()) do
                if item:IsA("Tool") and item:FindFirstChild("Handle") then
                    table.insert(fruits, {
                        Name = item.Name,
                        Instance = item,
                        Position = item.Handle.Position
                    })
                end
            end
        end
    end
    
    -- Check workspace for dropped fruits
    for _, item in pairs(self.Services.Workspace:GetChildren()) do
        if item:IsA("Tool") and string.find(item.Name, "Fruit") then
            if item:FindFirstChild("Handle") then
                table.insert(fruits, {
                    Name = item.Name,
                    Instance = item,
                    Position = item.Handle.Position
                })
            end
        end
    end
    
    return fruits
end

-- Get closest fruit
function FruitFinder:GetClosestFruit()
    local fruits = self:GetAllFruits()
    if #fruits == 0 then return nil end
    
    local hrp = self.Services:GetHumanoidRootPart()
    if not hrp then return fruits[1] end
    
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

-- Check if fruit exists
function FruitFinder:HasFruit()
    return #self:GetAllFruits() > 0
end

return FruitFinder
