--[[
    ================================================================
         AETHER HUB - BringMob Module (v3.0)
    ================================================================
    
    ADVANCED ENEMY MAGNETIZATION:
    ✓ Network ownership detection
    ✓ Multi-enemy bringing
    ✓ Hitbox expansion
    ✓ Collision disable
    ✓ Animation freeze
    ✓ SimulationRadius expansion
    
    BASED ON: Silver Hub Bring Mob System
    DEPENDENCIES: Services, Variables
]]

--// MODULE
local BringMob = {}
BringMob.__index = BringMob

--// DEPENDENCIES
local Services = nil
local Variables = nil

--// PRIVATE STATE
local _enabled = false
local _targetPosition = nil
local _bringRadius = 400
local _connections = {}

--// CONSTANTS
local HITBOX_SIZE = Vector3.new(60, 60, 60)
local NETWORK_RANGE = 350
local SIMULATION_RADIUS = math.huge

--[[
    Constructor
    @param services table
    @param variables table
]]
function BringMob.new(services, variables)
    local self = setmetatable({}, BringMob)
    
    Services = services or error("[BRINGMOB] Services required")
    Variables = variables or error("[BRINGMOB] Variables required")
    
    -- Setup simulation radius
    self:_setupSimulationRadius()
    
    -- Start bring loop
    self:_startBringLoop()
    
    return self
end

--[[
    PRIVATE: Check if object is in network ownership
    @param object Instance
    @return boolean
]]
function BringMob:_inMyNetwork(object)
    if not object or not object:IsA("BasePart") then
        return false
    end
    
    -- Use isnetworkowner if available (executor-specific)
    if isnetworkowner then
        local success, result = pcall(function()
            return isnetworkowner(object)
        end)
        
        if success then
            return result
        end
    end
    
    -- Fallback: distance check
    local hrp = Services:GetHumanoidRootPart()
    if not hrp then return false end
    
    local distance = (object.Position - hrp.Position).Magnitude
    return distance <= NETWORK_RANGE
end

--[[
    PRIVATE: Setup simulation radius expansion
]]
function BringMob:_setupSimulationRadius()
    task.spawn(function()
        while true do
            task.wait(1)
            
            pcall(function()
                if setscriptable then
                    setscriptable(Services.LocalPlayer, "SimulationRadius", true)
                end
                
                if sethiddenproperty then
                    sethiddenproperty(Services.LocalPlayer, "SimulationRadius", SIMULATION_RADIUS)
                end
            end)
        end
    end)
end

--[[
    PRIVATE: Bring mob loop
]]
function BringMob:_startBringLoop()
    task.spawn(function()
        while true do
            task.wait(0.1)
            
            if not _enabled or not _targetPosition then
                continue
            end
            
            pcall(function()
                self:_bringMobs()
            end)
        end
    end)
end

--[[
    PRIVATE: Bring all mobs to target position
]]
function BringMob:_bringMobs()
    local enemies = Services.Workspace.Enemies:GetChildren()
    
    for _, enemy in ipairs(enemies) do
        if self:_shouldBringMob(enemy) then
            self:_bringMob(enemy)
        end
    end
end

--[[
    PRIVATE: Check if mob should be brought
    @param enemy Model
    @return boolean
]]
function BringMob:_shouldBringMob(enemy)
    if not enemy or not enemy:IsA("Model") then
        return false
    end
    
    -- Skip bosses
    if string.find(enemy.Name, "Boss") then
        return false
    end
    
    local hrp = enemy:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Check distance
    local distance = (hrp.Position - _targetPosition.Position).Magnitude
    if distance > _bringRadius then
        return false
    end
    
    -- Check network ownership
    if not self:_inMyNetwork(hrp) then
        return false
    end
    
    -- Check humanoid
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    return true
end

--[[
    PRIVATE: Bring individual mob
    @param enemy Model
]]
function BringMob:_bringMob(enemy)
    local hrp = enemy:FindFirstChild("HumanoidRootPart")
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not humanoid then return end
    
    -- Move to target
    hrp.CFrame = _targetPosition
    
    -- Disable movement
    humanoid.JumpPower = 0
    humanoid.WalkSpeed = 0
    
    -- Expand hitbox
    hrp.Size = HITBOX_SIZE
    hrp.Transparency = 1
    
    -- Disable collision
    hrp.CanCollide = false
    
    local head = enemy:FindFirstChild("Head")
    if head then
        head.CanCollide = false
    end
    
    -- Freeze animation
    local animator = humanoid:FindFirstChild("Animator")
    if animator then
        animator:Destroy()
    end
    
    -- Change state to prevent escape
    humanoid:ChangeState(11)
    humanoid:ChangeState(14)
end

--[[
    PUBLIC: Enable bringing mobs
    @param targetPos CFrame
]]
function BringMob:Enable(targetPos)
    _enabled = true
    _targetPosition = targetPos
    print("[BRINGMOB] Enabled at position:", targetPos.Position)
end

--[[
    PUBLIC: Disable bringing mobs
]]
function BringMob:Disable()
    _enabled = false
    _targetPosition = nil
    print("[BRINGMOB] Disabled")
end

--[[
    PUBLIC: Update target position
    @param targetPos CFrame
]]
function BringMob:UpdatePosition(targetPos)
    _targetPosition = targetPos
end

--[[
    PUBLIC: Set bring radius
    @param radius number
]]
function BringMob:SetRadius(radius)
    if radius >= 100 and radius <= 1000 then
        _bringRadius = radius
        print("[BRINGMOB] Radius set to:", radius)
        return true
    end
    return false
end

--[[
    PUBLIC: Is enabled
    @return boolean
]]
function BringMob:IsEnabled()
    return _enabled
end

--[[
    PUBLIC: Get stats
    @return table
]]
function BringMob:GetStats()
    local count = 0
    
    if _enabled and _targetPosition then
        for _, enemy in ipairs(Services.Workspace.Enemies:GetChildren()) do
            if self:_shouldBringMob(enemy) then
                count = count + 1
            end
        end
    end
    
    return {
        Enabled = _enabled,
        TargetPosition = _targetPosition,
        BringRadius = _bringRadius,
        CurrentlyBringing = count
    }
end

--[[
    PUBLIC: Destroy
]]
function BringMob:Destroy()
    self:Disable()
    
    for _, connection in pairs(_connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    _connections = {}
end

return BringMob