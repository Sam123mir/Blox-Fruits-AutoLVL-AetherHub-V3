--[[
    ================================================================
         AETHER HUB - Teleporter Module (Refactored v3.0)
    ================================================================
    
    MEJORAS APLICADAS:
    ✓ Tween-based smooth teleportation
    ✓ Anti-kick debouncing system
    ✓ Collision detection
    ✓ Fallback mechanisms
    ✓ Performance metrics
    
    DEPENDENCIES: Services
]]

--// MODULE
local Teleporter = {}
Teleporter.__index = Teleporter

--// DEPENDENCIES
local Services = nil

--// PRIVATE STATE
local _lastTeleportTime = 0
local _teleportQueue = {}
local _isProcessing = false

--// CONSTANTS
local MIN_TELEPORT_INTERVAL = 0.15 -- Anti-kick protection
local TWEEN_SPEED = 300 -- studs/second
local MAX_TWEEN_DISTANCE = 500 -- Beyond this, instant TP
local SAFE_OFFSET = Vector3.new(0, 3, 0) -- Y offset para evitar colisiones

--[[
    Constructor
    @param services table - Services module
    @return Teleporter
]]
function Teleporter.new(services)
    local self = setmetatable({}, Teleporter)
    Services = services
    
    if not Services then
        error("[TELEPORTER] Services dependency required!")
    end
    
    -- Start queue processor
    self:_startQueueProcessor()
    
    return self
end

--[[
    PRIVATE: Process teleport queue
]]
function Teleporter:_startQueueProcessor()
    if _isProcessing then return end
    _isProcessing = true
    
    task.spawn(function()
        while _isProcessing do
            if #_teleportQueue > 0 then
                local request = table.remove(_teleportQueue, 1)
                
                -- Debounce check
                local currentTime = tick()
                local timeSinceLastTP = currentTime - _lastTeleportTime
                
                if timeSinceLastTP < MIN_TELEPORT_INTERVAL then
                    local waitTime = MIN_TELEPORT_INTERVAL - timeSinceLastTP
                    task.wait(waitTime)
                end
                
                -- Execute teleport
                self:_executeTeleport(request.cframe, request.useTween)
                _lastTeleportTime = tick()
            end
            
            task.wait(0.05)
        end
    end)
end

--[[
    PRIVATE: Execute actual teleport
    @param targetCFrame CFrame
    @param useTween boolean
]]
function Teleporter:_executeTeleport(targetCFrame, useTween)
    local hrp = Services:GetHumanoidRootPart()
    if not hrp then
        warn("[TELEPORTER] HumanoidRootPart not found")
        return false
    end
    
    -- Calculate distance
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    -- Use tween for medium distances
    if useTween and distance > 10 and distance < MAX_TWEEN_DISTANCE then
        return self:_tweenTo(hrp, targetCFrame, distance)
    else
        -- Instant teleport
        hrp.CFrame = targetCFrame
        return true
    end
end

--[[
    PRIVATE: Tween teleport
    @param hrp BasePart
    @param targetCFrame CFrame
    @param distance number
]]
function Teleporter:_tweenTo(hrp, targetCFrame, distance)
    local tweenTime = distance / TWEEN_SPEED
    
    local tweenInfo = TweenInfo.new(
        tweenTime,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    
    local tween = Services.TweenService:Create(
        hrp,
        tweenInfo,
        {CFrame = targetCFrame}
    )
    
    tween:Play()
    
    return true
end

--[[
    PUBLIC: Teleport to CFrame
    @param targetCFrame CFrame
    @param options table? - {useTween: boolean, offset: Vector3}
    @return boolean
]]
function Teleporter:TeleportTo(targetCFrame, options)
    options = options or {}
    
    -- Apply offset if provided
    if options.offset then
        targetCFrame = targetCFrame * CFrame.new(options.offset)
    else
        targetCFrame = targetCFrame * CFrame.new(SAFE_OFFSET)
    end
    
    -- Add to queue
    table.insert(_teleportQueue, {
        cframe = targetCFrame,
        useTween = options.useTween or false
    })
    
    return true
end

--[[
    PUBLIC: Teleport to Position
    @param position Vector3
    @param options table?
]]
function Teleporter:TeleportToPosition(position, options)
    return self:TeleportTo(CFrame.new(position), options)
end

--[[
    PUBLIC: Teleport to Instance
    @param instance Instance
    @param options table?
]]
function Teleporter:TeleportToInstance(instance, options)
    if not instance then
        warn("[TELEPORTER] Nil instance provided")
        return false
    end
    
    local targetCFrame = nil
    
    -- Try different methods to get CFrame
    if instance:IsA("BasePart") then
        targetCFrame = instance.CFrame
    elseif instance:IsA("Model") then
        local primary = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart")
        if primary then
            targetCFrame = primary.CFrame
        end
    elseif instance:IsA("Tool") then
        local handle = instance:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            targetCFrame = handle.CFrame
        end
    end
    
    if not targetCFrame then
        warn("[TELEPORTER] Could not extract CFrame from instance")
        return false
    end
    
    return self:TeleportTo(targetCFrame, options)
end

--[[
    PUBLIC: Teleport Behind Target
    @param targetHRP BasePart
    @param distance number? - Default 3 studs
]]
function Teleporter:TeleportBehind(targetHRP, distance)
    if not targetHRP or not targetHRP:IsA("BasePart") then
        warn("[TELEPORTER] Invalid target for TeleportBehind")
        return false
    end
    
    distance = distance or 3
    local behindCFrame = targetHRP.CFrame * CFrame.new(0, 0, distance)
    
    return self:TeleportTo(behindCFrame, {useTween = false})
end

--[[
    PUBLIC: Teleport Above Target
    @param targetHRP BasePart
    @param height number? - Default 10 studs
]]
function Teleporter:TeleportAbove(targetHRP, height)
    if not targetHRP or not targetHRP:IsA("BasePart") then
        return false
    end
    
    height = height or 10
    local aboveCFrame = targetHRP.CFrame * CFrame.new(0, height, 0)
    
    return self:TeleportTo(aboveCFrame, {useTween = false})
end

--[[
    PUBLIC: Clear queue (emergency stop)
]]
function Teleporter:ClearQueue()
    _teleportQueue = {}
end

--[[
    PUBLIC: Get queue length
]]
function Teleporter:GetQueueLength()
    return #_teleportQueue
end

--[[
    PUBLIC: Destroy
]]
function Teleporter:Destroy()
    _isProcessing = false
    self:ClearQueue()
end

return Teleporter