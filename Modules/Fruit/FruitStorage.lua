--[[
    AETHER HUB - Fruit Storage Module
    Stores Devil Fruits in player inventory
]]

local FruitStorage = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Services.lua"))()

-- Store current equipped fruit in inventory
function FruitStorage:StoreFruit()
    local success, result = pcall(function()
        if Services.CommF_ then
            return Services.CommF_:InvokeServer("StoreFruit")
        end
    end)
    
    return success, result
end

-- Get current equipped fruit name
function FruitStorage:GetEquippedFruit()
    local success, fruitName = pcall(function()
        local data = Services.LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("DevilFruit") then
            return data.DevilFruit.Value
        end
        return nil
    end)
    
    return success and fruitName or nil
end

-- Check if player has a fruit equipped
function FruitStorage:HasFruitEquipped()
    local fruit = self:GetEquippedFruit()
    return fruit ~= nil and fruit ~= ""
end

-- Get fruits in storage
function FruitStorage:GetStoredFruits()
    local fruits = {}
    
    local success = pcall(function()
        if Services.CommF_ then
            local inventory = Services.CommF_:InvokeServer("getInventoryFruits")
            if type(inventory) == "table" then
                for _, fruit in pairs(inventory) do
                    table.insert(fruits, fruit.Name or fruit)
                end
            end
        end
    end)
    
    return fruits
end

-- Equip a fruit from storage
function FruitStorage:EquipFruit(fruitName)
    local success, result = pcall(function()
        if Services.CommF_ then
            return Services.CommF_:InvokeServer("EquipFruit", fruitName)
        end
    end)
    
    return success, result
end

-- Eat a fruit (activate powers)
function FruitStorage:EatFruit()
    local success, result = pcall(function()
        local fruit = self:GetEquippedFruit()
        if fruit and Services.CommF_ then
            return Services.CommF_:InvokeServer("EatFruit", fruit)
        end
    end)
    
    return success, result
end

return FruitStorage
