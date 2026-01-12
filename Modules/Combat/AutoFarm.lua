--[[
    ================================================================
         AETHER HUB - AutoFarm Module (Refactored v3.0)
    ================================================================
    
    MEJORAS APLICADAS:
    ✓ State machine pattern
    ✓ Enemy tracking system
    ✓ Smart targeting (health, distance, threat)
    ✓ Performance optimizations
    ✓ Proper cleanup
    
    DEPENDENCIES: Services, Variables, Teleporter
]]

--// MODULE
local AutoFarm = {}
AutoFarm.__index = AutoFarm

--// DEPENDENCIES
local Services = nil
local Variables = nil
local Teleporter = nil

--// PRIVATE STATE
local _running = false
local _currentTarget = nil
local _enemyCache = {}
local _lastCacheUpdate = 0
local _connections = {}

--// CONSTANTS
local CACHE_LIFETIME = 1 -- seconds
local ATTACK_RANGE = 5
local ENEMY_CONTAINER_NAMES = {"Enemies", "Monster"}
local MIN_ENEMY_HEALTH = 10

--// STATES
local States = {
    IDLE = "Idle",
    SEARCHING = "Searching",
    APPROACHING = "Approaching",
    ATTACKING = "Attacking"
}

local _currentState = States.IDLE

--[[
    Constructor
    @param services table
    @param variables table
    @param teleporter table
]]
function AutoFarm.new(services, variables, teleporter)
    local self = setmetatable({}, AutoFarm)
    
    Services = services or error("[AUTOFARM] Services required")
    Variables = variables or error("[AUTOFARM] Variables required")
    Teleporter = teleporter or error("[AUTOFARM] Teleporter required")
    
    return self
end

--[[
    PUBLIC: Get Player Level
    @return number
]]
function AutoFarm:GetLevel()
    if not Services or not Services.LocalPlayer then
        return 0
    end
    
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if not data then return 0 end
    
    local levelValue = data:FindFirstChild("Level")
    if not levelValue then return 0 end
    
    return levelValue.Value or 0
end

--[[
    PRIVATE: Update enemy cache
]]
function AutoFarm:_updateEnemyCache()
    local currentTime = tick()
    
    -- Check if cache is still valid
    if currentTime - _lastCacheUpdate < CACHE_LIFETIME then
        return
    end
    
    _enemyCache = {}
    
    -- Find enemy containers
    for _, containerName in ipairs(ENEMY_CONTAINER_NAMES) do
        local container = Services.Workspace:FindFirstChild(containerName)
        if container then
            for _, enemy in ipairs(container:GetChildren()) do
                if self:_isValidEnemy(enemy) then
                    table.insert(_enemyCache, enemy)
                end
            end
        end
    end
    
    _lastCacheUpdate = currentTime
end

--[[
    PRIVATE: Validate enemy
    @param enemy Model
    @return boolean
]]
function AutoFarm:_isValidEnemy(enemy)
    if not enemy or not enemy:IsA("Model") then
        return false
    end
    
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= MIN_ENEMY_HEALTH then
        return false
    end
    
    local hrp = enemy:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then
        return false
    end
    
    return true
end

--[[
    PRIVATE: Find best target
    @return Model?, number? - enemy, distance
]]
function AutoFarm:_findBestTarget()
    self:_updateEnemyCache()
    
    local playerHRP = Services:GetHumanoidRootPart()
    if not playerHRP then return nil end
    
    local maxDistance = Variables:Get("FarmDistance") or 200
    
    local bestEnemy = nil
    local bestScore = -math.huge
    
    for _, enemy in ipairs(_enemyCache) do
        local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
        local humanoid = enemy:FindFirstChildOfClass("Humanoid")
        
        if enemyHRP and humanoid then
            local distance = (playerHRP.Position - enemyHRP.Position).Magnitude
            
            -- Skip if too far
            if distance > maxDistance then
                continue
            end
            
            -- Calculate score (closer + lower health = higher priority)
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local distanceScore = (maxDistance - distance) / maxDistance
            local score = distanceScore * 0.7 + (1 - healthPercent) * 0.3
            
            if score > bestScore then
                bestScore = score
                bestEnemy = enemy
            end
        end
    end
    
    if bestEnemy then
        local enemyHRP = bestEnemy:FindFirstChild("HumanoidRootPart")
        if enemyHRP then
            local distance = (playerHRP.Position - enemyHRP.Position).Magnitude
            return bestEnemy, distance
        end
    end
    
    return nil
end

--[[
    PRIVATE: Attack current target
]]
function AutoFarm:_attackTarget()
    if not _currentTarget then return false end
    
    local enemyHRP = _currentTarget:FindFirstChild("HumanoidRootPart")
    if not enemyHRP then
        _currentTarget = nil
        return false
    end
    
    -- Teleport behind enemy
    Teleporter:TeleportBehind(enemyHRP, ATTACK_RANGE)
    
    -- Activate weapon
    local character = Services:GetCharacter()
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Activate") then
            pcall(function()
                tool:Activate()
            end)
        end
    end
    
    return true
end

--[[
    PRIVATE: Main farm loop
]]
function AutoFarm:_farmLoop()
    while _running do
        -- Check if feature is enabled
        if not Variables:Get("AutoFarm") then
            task.wait(1)
            continue
        end
        
        -- State machine
        if _currentState == States.IDLE then
            _currentState = States.SEARCHING
            
        elseif _currentState == States.SEARCHING then
            local enemy, distance = self:_findBestTarget()
            
            if enemy then
                _currentTarget = enemy
                _currentState = States.APPROACHING
            else
                -- No enemies found, wait
                task.wait(2)
            end
            
        elseif _currentState == States.APPROACHING then
            if not self:_isValidEnemy(_currentTarget) then
                _currentTarget = nil
                _currentState = States.SEARCHING
            else
                local enemyHRP = _currentTarget:FindFirstChild("HumanoidRootPart")
                local playerHRP = Services:GetHumanoidRootPart()
                
                if enemyHRP and playerHRP then
                    local distance = (playerHRP.Position - enemyHRP.Position).Magnitude
                    
                    if distance <= ATTACK_RANGE * 2 then
                        _currentState = States.ATTACKING
                    else
                        Teleporter:TeleportBehind(enemyHRP, ATTACK_RANGE)
                    end
                end
            end
            
        elseif _currentState == States.ATTACKING then
            if not self:_isValidEnemy(_currentTarget) then
                _currentTarget = nil
                _currentState = States.SEARCHING
            else
                self:_attackTarget()
            end
        end
        
        -- Rate limiting
        local delay = Variables:Get("AttackDelay") or 0.1
        task.wait(delay)
    end
    
    _currentState = States.IDLE
end

--[[
    PUBLIC: Start AutoFarm
]]
function AutoFarm:Start()
    if _running then
        warn("[AUTOFARM] Already running")
        return
    end
    
    _running = true
    Variables:Set("AutoFarm", true)
    
    -- Start farm loop
    task.spawn(function()
        self:_farmLoop()
    end)
    
    print("[AUTOFARM] Started successfully")
end

--[[
    PUBLIC: Stop AutoFarm
]]
function AutoFarm:Stop()
    _running = false
    _currentTarget = nil
    _currentState = States.IDLE
    Variables:Set("AutoFarm", false)
    
    print("[AUTOFARM] Stopped")
end

--[[
    PUBLIC: Toggle AutoFarm
]]
function AutoFarm:Toggle()
    if _running then
        self:Stop()
    else
        self:Start()
    end
    return _running
end

--[[
    PUBLIC: Is Running
]]
function AutoFarm:IsRunning()
    return _running
end

--[[
    PUBLIC: Get Current State
]]
function AutoFarm:GetState()
    return _currentState
end

--[[
    PUBLIC: Cleanup
]]
function AutoFarm:Destroy()
    self:Stop()
    
    for _, connection in pairs(_connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    _connections = {}
    _enemyCache = {}
end

return AutoFarm