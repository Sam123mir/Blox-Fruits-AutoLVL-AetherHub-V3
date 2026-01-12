--[[
    AETHER HUB - AutoFarm Module (v3.1 - Simplified)
    Automatic enemy farming
]]

local AutoFarm = {}

-- Dependencies
local Services = nil
local Variables = nil
local Teleporter = nil

-- State
local _running = false
local _currentTarget = nil

-- Initialize
function AutoFarm.new(services, variables, teleporter)
    Services = services
    Variables = variables
    Teleporter = teleporter
    return AutoFarm
end

-- Get Level
function AutoFarm:GetLevel()
    if not Services or not Services.LocalPlayer then return 0 end
    
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 0
end

-- Find nearest enemy
function AutoFarm:FindNearestEnemy()
    if not Services then return nil end
    
    local enemies = Services.Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    local hrp = Services:GetHumanoidRootPart()
    if not hrp then return nil end
    
    local maxDistance = Variables and Variables:Get("FarmDistance") or 200
    local nearest = nil
    local nearestDist = math.huge
    
    for _, enemy in pairs(enemies:GetChildren()) do
        local humanoid = enemy:FindFirstChildOfClass("Humanoid")
        local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
        
        if humanoid and humanoid.Health > 0 and enemyHRP then
            local dist = (hrp.Position - enemyHRP.Position).Magnitude
            if dist < nearestDist and dist <= maxDistance then
                nearest = enemy
                nearestDist = dist
            end
        end
    end
    
    return nearest, nearestDist
end

-- Attack enemy
function AutoFarm:AttackEnemy(enemy)
    if not enemy or not Teleporter then return false end
    
    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not enemyHRP then return false end
    
    Teleporter:TeleportBehind(enemyHRP)
    
    local char = Services:GetCharacter()
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end
    end
    
    return true
end

-- Farm loop
function AutoFarm:_loop()
    while _running do
        if Variables and Variables:Get("AutoFarm") then
            local enemy = self:FindNearestEnemy()
            if enemy then
                _currentTarget = enemy
                self:AttackEnemy(enemy)
            else
                _currentTarget = nil
            end
        end
        
        local delay = Variables and Variables:Get("AttackDelay") or 0.1
        task.wait(delay)
    end
end

-- Start
function AutoFarm:Start()
    if _running then return end
    _running = true
    
    if Variables then
        Variables:Set("AutoFarm", true)
    end
    
    task.spawn(function()
        self:_loop()
    end)
    
    print("[AUTOFARM] Started")
end

-- Stop
function AutoFarm:Stop()
    _running = false
    _currentTarget = nil
    
    if Variables then
        Variables:Set("AutoFarm", false)
    end
    
    print("[AUTOFARM] Stopped")
end

-- Toggle
function AutoFarm:Toggle()
    if _running then
        self:Stop()
    else
        self:Start()
    end
    return _running
end

-- Is running
function AutoFarm:IsRunning()
    return _running
end

return AutoFarm