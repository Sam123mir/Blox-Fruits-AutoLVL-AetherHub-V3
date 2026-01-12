--[[
    AETHER HUB - AutoFarm Module
    Automatic level farming based on player level
]]

local AutoFarm = {}
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Services.lua"))()
local Variables = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Core/Variables.lua"))()
local Teleporter = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/Modules/Teleport/Teleporter.lua"))()

-- Internal state
AutoFarm._running = false
AutoFarm._currentMob = nil
AutoFarm._currentQuest = nil

-- Get player level
function AutoFarm:GetLevel()
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 0
end

-- Find nearest enemy
function AutoFarm:FindNearestEnemy()
    local enemies = Services.Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    local hrp = Services:GetHumanoidRootPart()
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, enemy in pairs(enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            if enemy:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    nearest = enemy
                    nearestDist = dist
                end
            end
        end
    end
    
    return nearest, nearestDist
end

-- Attack nearest enemy
function AutoFarm:AttackEnemy(enemy)
    if not enemy then return false end
    
    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not enemyHRP then return false end
    
    -- Teleport behind enemy
    Teleporter:TeleportBehind(enemyHRP)
    
    -- Click to attack
    local tool = Services.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
    
    return true
end

-- Start auto farm loop
function AutoFarm:Start()
    if self._running then return end
    self._running = true
    
    spawn(function()
        while self._running and Variables.AutoFarm do
            local enemy, dist = self:FindNearestEnemy()
            if enemy and dist < Variables.FarmDistance then
                self:AttackEnemy(enemy)
            end
            wait(Variables.AttackDelay)
        end
        self._running = false
    end)
end

-- Stop auto farm
function AutoFarm:Stop()
    self._running = false
    Variables.AutoFarm = false
end

-- Toggle auto farm
function AutoFarm:Toggle()
    Variables.AutoFarm = not Variables.AutoFarm
    if Variables.AutoFarm then
        self:Start()
    else
        self:Stop()
    end
    return Variables.AutoFarm
end

return AutoFarm
