--[[
    AETHER HUB - FruitStorage Module (v3.1 - Simplified)
    Stores fruits in inventory
]]

local FruitStorage = {}

-- Dependencies
local Services = nil

-- Initialize
function FruitStorage.new(services)
    Services = services
    return FruitStorage
end

-- Store fruit
function FruitStorage:StoreFruit()
    if not Services then return false, "Services not loaded" end
    
    if not self:HasFruit() then
        return false, "No fruit equipped"
    end
    
    local commF = Services:GetCommF()
    if not commF then
        return false, "CommF_ not found"
    end
    
    local success = pcall(function()
        commF:InvokeServer("StoreFruit")
    end)
    
    if success then
        return true, "Fruit stored!"
    else
        return false, "Failed to store"
    end
end

-- Get equipped fruit
function FruitStorage:GetEquippedFruit()
    if not Services or not Services.LocalPlayer then return nil end
    
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("DevilFruit") then
        local value = data.DevilFruit.Value
        if value and value ~= "" then
            return value
        end
    end
    return nil
end

-- Has fruit
function FruitStorage:HasFruit()
    return self:GetEquippedFruit() ~= nil
end

return FruitStorage