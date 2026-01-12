--[[
    AETHER HUB - Fruit Storage Module
    Stores fruits in inventory
    Requires: Services (passed via init)
]]

local FruitStorage = {}
FruitStorage.Services = nil

function FruitStorage:Init(services)
    self.Services = services
    return self
end

-- Store current fruit
function FruitStorage:StoreFruit()
    if not self.Services then return false end
    
    local commF = self.Services:GetCommF()
    if commF then
        local success = pcall(function()
            commF:InvokeServer("StoreFruit")
        end)
        return success
    end
    return false
end

-- Get equipped fruit name
function FruitStorage:GetEquippedFruit()
    if not self.Services then return nil end
    
    local data = self.Services.LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("DevilFruit") then
        return data.DevilFruit.Value
    end
    return nil
end

-- Check if has fruit
function FruitStorage:HasFruit()
    local fruit = self:GetEquippedFruit()
    return fruit ~= nil and fruit ~= ""
end

return FruitStorage
