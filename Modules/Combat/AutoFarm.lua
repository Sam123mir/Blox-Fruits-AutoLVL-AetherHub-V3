--[[
    AETHER HUB - AutoFarm Module
    Automatic enemy farming
    Requires: Services, Variables, Teleporter (passed via init)
]]

local AutoFarm = {}
AutoFarm.Services = nil
AutoFarm.Variables = nil
AutoFarm.Teleporter = nil
AutoFarm._running = false

function AutoFarm:Init(services, variables, teleporter)
    self.Services = services
    self.Variables = variables
    self.Teleporter = teleporter
    return self
end

-- Get player level
function AutoFarm:GetLevel()
    if not self.Services then return 0 end
    
    local data = self.Services.LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 0
end

-- Find nearest enemy
function AutoFarm:FindNearestEnemy()
    if not self.Services then return nil end
    
    local enemies = self.Services.Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    local hrp = self.Services:GetHumanoidRootPart()
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

-- Attack enemy
function AutoFarm:AttackEnemy(enemy)
    if not enemy or not self.Teleporter then return false end
    
    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not enemyHRP then return false end
    
    self.Teleporter:TeleportBehind(enemyHRP)
    
    local tool = self.Services.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
    
    return true
end

-- Start auto farm
function AutoFarm:Start()
    if self._running then return end
    self._running = true
    
    spawn(function()
        while self._running and self.Variables and self.Variables.AutoFarm do
            local enemy, dist = self:FindNearestEnemy()
            if enemy and dist < (self.Variables.FarmDistance or 200) then
                self:AttackEnemy(enemy)
            end
            wait(self.Variables.AttackDelay or 0.1)
        end
        self._running = false
    end)
end

-- Stop auto farm
function AutoFarm:Stop()
    self._running = false
    if self.Variables then
        self.Variables.AutoFarm = false
    end
end

return AutoFarm
