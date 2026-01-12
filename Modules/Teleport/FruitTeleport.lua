--[[
    AETHER HUB - Fruit Teleport Module
    Auto teleport to Devil Fruits when they spawn
]]

local FruitTeleport = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Services.lua"))()
local Variables = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Variables.lua"))()
local FruitFinder = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Fruit/FruitFinder.lua"))()
local FruitStorage = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Fruit/FruitStorage.lua"))()
local Teleporter = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Teleport/Teleporter.lua"))()

-- Internal state
FruitTeleport._running = false
FruitTeleport._connection = nil
FruitTeleport._onFruitFound = nil

-- Callback when fruit is found
function FruitTeleport:SetOnFruitFound(callback)
    self._onFruitFound = callback
end

-- Teleport to the closest fruit
function FruitTeleport:TeleportToClosestFruit()
    local fruit = FruitFinder:GetClosestFruit()
    if fruit then
        -- Notify callback
        if self._onFruitFound then
            self._onFruitFound(fruit.Name, fruit.Distance)
        end
        
        -- Teleport to fruit
        Teleporter:TeleportToInstance(fruit.Instance)
        return fruit
    end
    return nil
end

-- Start auto teleport loop
function FruitTeleport:Start()
    if self._running then return end
    self._running = true
    
    spawn(function()
        while self._running do
            if Variables.FruitTeleport then
                local fruit = self:TeleportToClosestFruit()
                
                if fruit and Variables.FruitAutoStore then
                    -- Wait a bit to pick up the fruit
                    wait(0.5)
                    -- Try to store it
                    FruitStorage:StoreFruit()
                end
            end
            wait(1)
        end
    end)
end

-- Stop auto teleport
function FruitTeleport:Stop()
    self._running = false
end

-- Toggle auto teleport
function FruitTeleport:Toggle()
    if self._running then
        self:Stop()
    else
        self:Start()
    end
    return self._running
end

-- Get current status
function FruitTeleport:IsRunning()
    return self._running
end

return FruitTeleport
