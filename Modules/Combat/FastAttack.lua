--[[
    AETHER HUB - PROFESSIONAL FAST ATTACK v5.0
    ============================================================================
    Sistema de combate de alto rendimiento diseñado para Blox Fruits.
    Utiliza técnicas de optimización de hilos y manipulación del 
    CombatFramework mediante inyección de dependencias.
    
    INGENIERÍA:
    - State Machine (Enabled/Disabled/Cooldown)
    - Batched Hit Detection (GetPartBoundsInRadius)
    - Intelligent Weapon Scraper
    - Event-Driven integration con Variables.lua
]]

local FastAttack = {}
FastAttack.__index = FastAttack

--// Type Definitions
export type FastAttackConfig = {
    AttackSpeed: number,
    HitboxRadius: number,
    MultiTarget: boolean,
    AutoEquip: boolean
}

--// Constants
local ATTACK_REMOTES = {"Attack", "RegisterAttack", "WeaponAttack"}
local DEFAULT_CONFIG: FastAttackConfig = {
    AttackSpeed = 0.12, -- Balanceado para evitar kick
    HitboxRadius = 60,
    MultiTarget = true,
    AutoEquip = true
}

--[[
    CONSTRUCTOR
    @param services table - Services Module
    @param variables table - Variables Module
]]
function FastAttack.new(services, variables)
    local self = setmetatable({}, FastAttack)
    
    self._services = services or error("[FASTATTACK] Services required")
    self._vars = variables or error("[FASTATTACK] Variables required")
    
    -- State
    self._enabled = false
    self._lastAttack = 0
    self._targets = {}
    self._activeConnections = {}
    self._config = DEFAULT_CONFIG
    
    -- Cache
    self._combatFramework = nil
    self._equippedWeapon = nil
    
    self:_initialize()
    
    print("[FASTATTACK] Professional Module Initialized")
    return self
end

--[[
    PRIVATE: Initialize system and observers
]]
function FastAttack:_initialize()
    -- Observar cambios en Variables.lua
    self._activeConnections.toggle = self._vars:Observe("FastAttack", function(enabled)
        if enabled then
            self:Enable()
        else
            self:Disable()
        end
    end)
    
    -- Sincronizar configuración inicial
    self:UpdateConfig({
        AttackSpeed = math.clamp(self._vars:Get("FastAttackSpeed", 0.12), 0.05, 0.5),
        HitboxRadius = self._vars:Get("HitboxRadius", 60)
    })
    
    -- Intentar obtener CombatFramework proactivamente
    task.spawn(function()
        self:_setupCombatFramework()
    end)
end

--[[
    PRIVATE: Setup CombatFramework using upvalues
]]
function FastAttack:_setupCombatFramework()
    local success, result = pcall(function()
        local playerScripts = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts")
        if not playerScripts then return nil end
        
        local combatModule = playerScripts:FindFirstChild("CombatFramework")
        if combatModule then
            local framework = require(combatModule)
            -- Intentar obtener activeController si existe
            return framework
        end
    end)
    
    if success and result then
        self._combatFramework = result
    end
end

--[[
    PUBLIC: Enable the system
]]
function FastAttack:Enable()
    if self._enabled then return end
    self._enabled = true
    
    task.spawn(function()
        self:_combatLoop()
    end)
    
    print("[FASTATTACK] System Enabled")
end

--[[
    PUBLIC: Disable the system
]]
function FastAttack:Disable()
    self._enabled = false
    print("[FASTATTACK] System Disabled")
end

--[[
    PRIVATE: Main Combat Loop
    Optimizado para el Task Scheduler de 2026
]]
function FastAttack:_combatLoop()
    while self._enabled do
        local currentTime = tick()
        
        if currentTime - self._lastAttack >= self._config.AttackSpeed then
            local character = self._services:GetCharacter()
            local hrp = self._services:GetHumanoidRootPart()
            
            if character and hrp then
                local targets = self:_findTargets(hrp.Position)
                
                if #targets > 0 then
                    self:_executeAttack(targets)
                    self._lastAttack = currentTime
                end
            end
        end
        
        task.wait() -- Máxima frecuencia, controlada por la lógica de tiempo
    end
end

--[[
    PRIVATE: Find targets in radius using modern Roblox API
]]
function FastAttack:_findTargets(position: Vector3)
    local targets = {}
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {self._services:GetCharacter()}
    
    local parts = workspace:GetPartBoundsInRadius(position, self._config.HitboxRadius, params)
    
    for _, part in ipairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and not table.find(targets, model) then
                table.insert(targets, model)
                if not self._config.MultiTarget then break end
            end
        end
    end
    
    return targets
end

--[[
    PRIVATE: Execute the attack via Service remotes
]]
function FastAttack:_executeAttack(targets)
    -- Auto equip if needed
    if self._config.AutoEquip then
        self:_ensureWeaponEquipped()
    end
    
    -- Blox Fruits specific attack logic
    -- Usamos el InvokeCommF de Services que ya tiene reintentos y robustez
    for _, target in ipairs(targets) do
        local targetHrp = target:FindFirstChild("HumanoidRootPart")
        if targetHrp then
            -- Intentar llamar al remote de ataque (patrón estándar Blox Fruits)
            self._services:InvokeCommF("Attack", targetHrp)
        end
    end
end

--[[
    PRIVATE: Ensure a weapon is equipped
]]
function Services:_ensureWeaponEquipped()
    local char = self._services:GetCharacter()
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        -- Buscar en mochila
        local bp = self._services.LocalPlayer:FindFirstChild("Backpack")
        if bp then
            local weapon = bp:FindFirstChildOfClass("Tool") -- Simplificado: agarra la primera
            if weapon then
                weapon.Parent = char
            end
        end
    end
end

--[[
    PUBLIC: Update local configuration
]]
function FastAttack:UpdateConfig(newConfig: table)
    for k, v in pairs(newConfig) do
        if self._config[k] ~= nil then
            self._config[k] = v
        end
    end
end

--[[
    CLEANUP
]]
function FastAttack:Destroy()
    self:Disable()
    for _, conn in pairs(self._activeConnections) do
        if conn.Disconnect then conn:Disconnect() end
    end
    table.clear(self._activeConnections)
end

return FastAttack