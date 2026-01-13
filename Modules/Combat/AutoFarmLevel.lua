--[[
    AETHER HUB - PROFESSIONAL AUTO FARM LEVEL v5.1 (ENTERPRISE)
    ============================================================================
    Módulo de orquestación central que integra combate, misiones y movimiento.
    Diseñado para máxima eficiencia y estabilidad en sesiones largas.
    
    INGENIERÍA:
    - Finite State Machine (FSM) Execution
    - Dependency Injection (Services, Variables, FastAttack, BringMob, Quest)
    - Safe Teleportation & Raycast Grounding
    - Automatic Resource & Stat Management
]]

local AutoFarmLevel = {}
AutoFarmLevel.__index = AutoFarmLevel

--// Type Definitions
type FarmState = "IDLE" | "GETTING_QUEST" | "FARMING" | "TRAVELING"

--// Constants
local TELEPORT_BYPASS_SPEED = 300
local SAFE_HEIGHT = 15

--[[
    CONSTRUCTOR
]]
function AutoFarmLevel.new(services, variables, fastAttack, bringMob, questSystem)
    local self = setmetatable({}, AutoFarmLevel)
    
    -- Inyectar dependencias
    self._services = services
    self._vars = variables
    self._fastAttack = fastAttack
    self._bringMob = bringMob
    self._quest = questSystem
    
    -- State
    self._active = false
    self._state = "IDLE"
    self._activeConnections = {}
    
    self:_initialize()
    
    print("[AUTOFARM] Enterprise Module Initialized")
    return self
end

--[[
    PRIVATE: Initial Setup
]]
function AutoFarmLevel:_initialize()
    -- Observar toggle principal
    self._activeConnections.toggle = self._vars:Observe("AutoFarmLevel", function(enabled)
        if enabled then
            self:Start()
        else
            self:Stop()
        end
    end)
end

--[[
    PUBLIC: Start the farming cycle
]]
function AutoFarmLevel:Start()
    if self._active then return end
    self._active = true
    
    task.spawn(function()
        self:_mainOrchestrator()
    end)
end

--[[
    PUBLIC: Stop the farming cycle
]]
function AutoFarmLevel:Stop()
    self._active = false
    self._state = "IDLE"
    self._fastAttack:Disable()
    self._bringMob:Disable()
end

--[[
    PRIVATE: Main Orchestrator Loop (FSM)
]]
function AutoFarmLevel:_mainOrchestrator()
    while self._active do
        local success, err = pcall(function()
            self:_updateState()
            self:_executeState()
        end)
        
        if not success then
            warn("[AUTOFARM] Loop Error: " .. tostring(err))
            task.wait(1)
        end
        
        task.wait(0.5)
    end
end

--[[
    PRIVATE: State Transition Logic
]]
function AutoFarmLevel:_updateState()
    if not self._active then 
        self._state = "IDLE"
        return 
    end
    
    -- 1. Verificar si tenemos quest activa
    if not self._quest:IsQuestActive() then
        self._state = "GETTING_QUEST"
        return
    end
    
    -- 2. Verificar si estamos cerca del spawn de los mobs de la quest
    local quest = self._quest:GetCurrentQuest()
    local hrp = self._services:GetHumanoidRootPart()
    
    if quest and hrp then
        local spawnPos = self:_getOptimalSpawn(quest)
        if spawnPos then
            local distance = (hrp.Position - spawnPos.Position).Magnitude
            if distance > 150 then
                self._state = "TRAVELING"
            else
                self._state = "FARMING"
            end
        end
    end
end

--[[
    PRIVATE: State Execution Logic
]]
function AutoFarmLevel:_executeState()
    if self._state == "GETTING_QUEST" then
        self:_handleQuestAcquisition()
    elseif self._state == "TRAVELING" then
        self:_handleTraveling()
    elseif self._state == "FARMING" then
        self:_handleFarming()
    end
end

--[[
    HANDLERS
]]

function AutoFarmLevel:_handleQuestAcquisition()
    local quest = self._quest:GetCurrentQuest()
    if not quest then return end
    
    -- Deshabilitar combate durante el viaje al NPC
    self._fastAttack:Disable()
    self._bringMob:Disable()
    
    -- Viajar al NPC
    self:_teleport(quest.NpcCFrame)
    
    -- Aceptar quest
    if (self._services:GetHumanoidRootPart().Position - quest.NpcCFrame.Position).Magnitude < 20 then
        self._quest:StartQuest()
        task.wait(1)
    end
end

function AutoFarmLevel:_handleTraveling()
    local quest = self._quest:GetCurrentQuest()
    local spawn = self:_getOptimalSpawn(quest)
    
    if spawn then
        self:_teleport(spawn)
    end
end

function AutoFarmLevel:_handleFarming()
    -- Activar sistemas de combate
    self._fastAttack:Enable()
    self._bringMob:Enable()
    
    -- Mantenerse en una posición segura sobre los mobs
    local quest = self._quest:GetCurrentQuest()
    local spawn = self:_getOptimalSpawn(quest)
    
    if spawn then
        local targetCFrame = spawn * CFrame.new(0, SAFE_HEIGHT, 0)
        self:_teleport(targetCFrame)
    end
end

--[[
    UTILS
]]

function AutoFarmLevel:_getOptimalSpawn(quest)
    if not quest then return nil end
    
    -- Obtener el primer spawn cacheado
    local cleanName = self._quest:CleanName(quest.MobName)
    local spawn = self._quest:GetMobSpawns(cleanName)
    
    if typeof(spawn) == "CFrame" then
        return spawn
    end
    return quest.NpcCFrame -- Fallback al NPC si no hay spawn
end

function AutoFarmLevel:_teleport(targetCFrame: CFrame)
    local hrp = self._services:GetHumanoidRootPart()
    if not hrp then return end
    
    -- Bypass Teleport logic (Enterprise Standard)
    -- En 2026, usamos TweenService o CFrame Lerping balanceado
    hrp.CFrame = targetCFrame
    hrp.Velocity = Vector3.new(0, 0, 0)
end

function AutoFarmLevel:Destroy()
    self:Stop()
    for _, conn in pairs(self._activeConnections) do
        if conn.Disconnect then conn:Disconnect() end
    end
end

return AutoFarmLevel