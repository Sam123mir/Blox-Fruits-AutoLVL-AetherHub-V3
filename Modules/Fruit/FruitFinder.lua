--[[
    AETHER HUB - Fruit Finder Module
    Detects Devil Fruits spawned in the map
]]

local FruitFinder = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Services.lua"))()

-- Fruit spawn locations in workspace
local FRUIT_CONTAINERS = {
    "Fruits",
    "AppleSpawner", 
    "PineappleSpawner"
}

-- Find all Devil Fruits in the map
function FruitFinder:GetAllFruits()
    local fruits = {}
    
    -- Check workspace for fruits
    for _, containerName in ipairs(FRUIT_CONTAINERS) do
        local container = Services.Workspace:FindFirstChild(containerName)
        if container then
            for _, item in pairs(container:GetChildren()) do
                if item:IsA("Tool") and item:FindFirstChild("Handle") then
                    table.insert(fruits, {
                        Name = item.Name,
                        Instance = item,
                        Position = item.Handle.Position,
                        Distance = self:GetDistanceToFruit(item)
                    })
                end
            end
        end
    end
    
    -- Check ground for dropped fruits
    for _, item in pairs(Services.Workspace:GetChildren()) do
        if item:IsA("Tool") and string.find(item.Name, "Fruit") then
            if item:FindFirstChild("Handle") then
                table.insert(fruits, {
                    Name = item.Name,
                    Instance = item,
                    Position = item.Handle.Position,
                    Distance = self:GetDistanceToFruit(item)
                })
            end
        end
    end
    
    return fruits
end

-- Get distance to a fruit
function FruitFinder:GetDistanceToFruit(fruit)
    local hrp = Services:GetHumanoidRootPart()
    if hrp and fruit:FindFirstChild("Handle") then
        return (hrp.Position - fruit.Handle.Position).Magnitude
    end
    return math.huge
end

-- Find the closest fruit
function FruitFinder:GetClosestFruit()
    local fruits = self:GetAllFruits()
    local closest = nil
    local closestDistance = math.huge
    
    for _, fruit in ipairs(fruits) do
        if fruit.Distance < closestDistance then
            closest = fruit
            closestDistance = fruit.Distance
        end
    end
    
    return closest
end

-- Check if any fruit exists in the map
function FruitFinder:HasFruitSpawned()
    return #self:GetAllFruits() > 0
end

-- Get fruit names list
function FruitFinder:GetFruitNames()
    local names = {}
    for _, fruit in ipairs(self:GetAllFruits()) do
        table.insert(names, fruit.Name)
    end
    return names
end

return FruitFinder
