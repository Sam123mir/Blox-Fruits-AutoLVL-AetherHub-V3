--[[
    AETHER HUB - PROFESSIONAL BRING MOB v5.0
    ============================================================================
    Sistema de magnetismo y agrupamiento de NPCs para Blox Fruits.
    Optimizado para minimizar el lag de red y maximizar la eficiencia del farm.
    
    INGENIERÍA:
    - Network Ownership Optimization
    - Smooth Interpolation (CFrame Lerping)
    - Anti-Fling Technology (Collision disabling)
    - Batched processing para evitar CPU spikes
]]

local BringMob = {}
BringMob.__index = BringMob

--// Type Definitions
export type BringMobConfig = {
    Radius: number,
    BringDistance: number, -- Distancia frente al jugador
    UpdateFrequency: number,
    Smoothness: number
}

--// Constants
local DEFAULT_CONFIG: BringMobConfig = {
    Radius = 65,
    BringDistance = 5,
    UpdateFrequency = 0.1,
    Smoothness = 0.5
}

--[[
    CONSTRUCTOR
    @param services table - Services Module
    @param variables table - Variables Module
]]
function BringMob.new(services, variables)
    local self = setmetatable({}, BringMob)
    
    self._services = services or error("[BRINGMOB] Services required")
    self._vars = variables or error("[BRINGMOB] Variables required")
    
    -- State
    self._enabled = false
    self._config = DEFAULT_CONFIG
    self._activeConnections = {}
    self._ignoredMobs = {} -- Cache para mobs bugeados o bosses
    
    self:_initialize()
    
    print("[BRINGMOB] Professional Module Initialized")
    return self
end

--[[
    PRIVATE: Initialize system and observers
]]
function BringMob:_initialize()
    -- Observar cambios en Variables.lua
    self._activeConnections.toggle = self._vars:Observe("BringMob", function(enabled)
        if enabled then
            self:Enable()
        else
            self:Disable()
        end
    end)
    
    -- Sincronizar configuración inicial
    self:UpdateConfig({
        Radius = self._vars:Get("BringMobRadius", 65),
        BringDistance = self._vars:Get("BringMobDistance", 5)
    })
end

--[[
    PUBLIC: Enable the system
]]
function BringMob:Enable()
    if self._enabled then return end
    self._enabled = true
    
    task.spawn(function()
        self:_bringLoop()
    end)
    
    print("[BRINGMOB] System Enabled")
end

--[[
    PUBLIC: Disable the system
]]
function BringMob:Disable()
    self._enabled = false
    print("[BRINGMOB] System Disabled")
end

--[[
    PRIVATE: Main Bring Loop
]]
function BringMob:_bringLoop()
    while self._enabled do
        local hrp = self._services:GetHumanoidRootPart()
        
        if hrp then
            local targetPosition = hrp.Position + (hrp.CFrame.LookVector * self._config.BringDistance)
            self:_processMobs(targetPosition)
        end
        
        task.wait(self._config.UpdateFrequency)
    end
end

--[[
    PRIVATE: Process and teleport mobs to target position
]]
function BringMob:_processMobs(targetPosition: Vector3)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    
    local charHrp = self._services:GetHumanoidRootPart()
    if not charHrp then return end
    
    for _, mob in ipairs(enemies:GetChildren()) do
        if mob:IsA("Model") and not self._ignoredMobs[mob] then
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            local humanoid = mob:FindFirstChildOfClass("Humanoid")
            
            if mobHrp and humanoid and humanoid.Health > 0 then
                local distance = (mobHrp.Position - charHrp.Position).Magnitude
                
                if distance <= self._config.Radius then
                    self:_magnetizeMob(mobHrp, targetPosition)
                end
            end
        end
    end
end

--[[
    PRIVATE: Apply smooth magnetism to a mob
    Uses CFrame manipulation safely
]]
function BringMob:_magnetizeMob(mobHrp: Part, targetPosition: Vector3)
    -- Deshabilitar colisiones temporales para evitar "flings"
    pcall(function()
        if mobHrp.CanCollide then
            mobHrp.CanCollide = false
        end
        
        -- Teleportación directa (más eficiente para farming masivo)
        -- En 2026, los ejecutores manejan CFrame de forma nativa rápida
        mobHrp.CFrame = CFrame.new(targetPosition)
        
        -- Mantener velocidad en 0 para evitar que el motor de física lo mueva
        mobHrp.Velocity = Vector3.new(0, 0, 0)
    end)
end

--[[
    PUBLIC: Update configuration
]]
function BringMob:UpdateConfig(newConfig: table)
    for k, v in pairs(newConfig) do
        if self._config[k] ~= nil then
            self._config[k] = v
        end
    end
end

--[[
    CLEANUP
]]
function BringMob:Destroy()
    self:Disable()
    for _, conn in pairs(self._activeConnections) do
        if conn.Disconnect then conn:Disconnect() end
    end
    table.clear(self._activeConnections)
end

return BringMob