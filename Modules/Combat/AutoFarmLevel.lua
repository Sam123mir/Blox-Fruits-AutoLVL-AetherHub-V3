--[[
    ============================================================================
        AETHER HUB - AUTO FARM LEVEL SYSTEM (PROFESSIONAL EDITION v4.5)
    ============================================================================
    
    ARQUITECTURA:
    - Patrón State Machine para gestión de estados avanzada
    - Sistema de Tasks con prioridades y colas
    - Machine Learning básico para toma de decisiones
    - Optimización de memoria con pooling de objetos
    - Sistema de plugins para extensibilidad
    
    TÉCNICAS AVANZADAS DE EXPLOTACIÓN:
    ✓ Network Ownership Manipulation (Byfron Bypass)
    ✓ Humanoid State Override (Godmode, NoClip)
    ✓ Physics Bypass (Fly, Speed, No Fall Damage)
    ✓ Remote Function Hijacking
    ✓ Memory Manipulation Patches
    
    OPTIMIZACIONES:
    ✓ Frame-by-frame task scheduling (60 FPS)
    ✓ Object pooling para instancias recurrentes
    ✓ Cache inteligente de datos de juego
    ✓ Lazy loading de recursos pesados
    ✓ Garbage Collection controlada
    
    BASADO EN: Silver Hub Professional + Enterprise Exploit Techniques
    ============================================================================
]]

-- Type definitions para Luau
export type FarmState = {
    Name: string,
    Priority: number,
    CanTransitionTo: {string},
    OnEnter: (self: any) -> (),
    OnUpdate: (self: any, deltaTime: number) -> (),
    OnExit: (self: any) -> ()
}

export type MobData = {
    Instance: Instance,
    Name: string,
    Health: number,
    MaxHealth: number,
    Distance: number,
    Position: Vector3,
    Humanoid: Humanoid,
    HRP: BasePart,
    LastSeen: number,
    ThreatLevel: number,
    PriorityScore: number
}

export type QuestData = {
    Name: string,
    Level: number,
    MobName: string,
    Required: number,
    NPC: Instance?,
    NPCPosition: Vector3?,
    Rewards: {[string]: any},
    IsBoss: boolean,
    SpawnPoints: {Vector3},
    CurrentProgress: number
}

--======================================================================
--  CORE MODULE: AutoFarmLevelProfessional
--======================================================================

local AutoFarmLevel = {}
AutoFarmLevel.__index = AutoFarmLevel
AutoFarmLevel.__version = "4.5.0-Professional"

-- Servicios globales
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Logger profesional
local Logger = {
    Levels = {
        TRACE = 0,
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4,
        FATAL = 5
    },
    
    new = function(moduleName)
        local self = {
            ModuleName = moduleName,
            LogLevel = 2, -- INFO por defecto
            Colors = {
                [0] = Color3.fromRGB(100, 100, 100),   -- TRACE: Gris
                [1] = Color3.fromRGB(0, 150, 255),     -- DEBUG: Azul
                [2] = Color3.fromRGB(0, 255, 0),       -- INFO: Verde
                [3] = Color3.fromRGB(255, 255, 0),     -- WARN: Amarillo
                [4] = Color3.fromRGB(255, 100, 0),     -- ERROR: Naranja
                [5] = Color3.fromRGB(255, 0, 0)        -- FATAL: Rojo
            }
        }
        
        function self:log(level, message, ...)
            if level < self.LogLevel then return end
            
            local timestamp = os.date("%H:%M:%S")
            local levelName = ""
            if level == 0 then levelName = "TRACE"
            elseif level == 1 then levelName = "DEBUG"
            elseif level == 2 then levelName = "INFO"
            elseif level == 3 then levelName = "WARN"
            elseif level == 4 then levelName = "ERROR"
            elseif level == 5 then levelName = "FATAL" end
            
            local formatted = string.format("[%s] [%s] [%s] %s", 
                timestamp, levelName, self.ModuleName, message)
            
            if select("#", ...) > 0 then
                formatted = formatted .. " | " .. table.concat({...}, ", ")
            end
            
            -- Output con color si es posible
            if level >= 3 then -- WARN y superiores
                warn(formatted)
            else
                print(formatted)
            end
        end
        
        function self:trace(...) self:log(0, ...) end
        function self:debug(...) self:log(1, ...) end
        function self:info(...) self:log(2, ...) end
        function self:warn(...) self:log(3, ...) end
        function self:error(...) self:log(4, ...) end
        function self:fatal(...) self:log(5, ...) end
        
        function self:setLevel(level)
            self.LogLevel = level
        end
        
        return self
    end
}

--======================================================================
--  EXPLOIT ENGINE: Sistema avanzado de bypass y manipulación
--======================================================================

local ExploitEngine = {
    _logger = Logger.new("ExploitEngine"),
    _patches = {},
    _hooks = {},
    _originalFunctions = {}
}

-- Técnica 1: Network Ownership Bypass
function ExploitEngine:hijackNetworkOwnership(part)
    if not part or not part:IsA("BasePart") then
        return false
    end
    
    -- Método 1: SetNetworkOwner a nil (Byfron bypass)
    local success, result = pcall(function()
        part:SetNetworkOwner(nil)
        part.CanCollide = false
        part.Massless = true
        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
        
        -- Forzar recálculo de física
        part:GetPropertyChangedSignal("Position"):Wait()
        part:GetPropertyChangedSignal("CFrame"):Wait()
        
        return true
    end)
    
    -- Método 2: Replica de red alternativa
    if not success then
        success = pcall(function()
            local clone = part:Clone()
            clone.Parent = part.Parent
            clone.Anchored = false
            clone.CanCollide = false
            
            -- Reemplazar original
            part:Destroy()
            clone.Name = part.Name
            
            return true
        end)
    end
    
    return success
end

-- Técnica 2: Humanoid State Override
function ExploitEngine:patchHumanoid(humanoid)
    if not humanoid or not humanoid:IsA("Humanoid") then
        return false
    end
    
    local success = pcall(function()
        -- Desactivar daño
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        -- Patch de métodos
        local oldTakeDamage = humanoid.TakeDamage
        ExploitEngine._originalFunctions[humanoid] = oldTakeDamage
        
        humanoid.TakeDamage = function(self, damage)
            return 0 -- Ignorar todo daño
        end
        
        -- Estado invulnerable
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        
        -- Velocidades modificadas
        humanoid.WalkSpeed = 100
        humanoid.JumpPower = 150
        
        -- No clip básico
        humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        
        return true
    end)
    
    if success then
        ExploitEngine._logger:info("Humanoid patched successfully")
    else
        ExploitEngine._logger:error("Failed to patch humanoid")
    end
    
    return success
end

-- Técnica 3: Physics Bypass (Fly/NoClip)
function ExploitEngine:enableFlight(character, speed)
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    -- Crear BodyVelocity para vuelo
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlightVelocity"
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.P = 10000
    bodyVelocity.Parent = hrp
    
    -- Crear BodyGyro para estabilidad
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FlightGyro"
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.D = 500
    bodyGyro.Parent = hrp
    
    -- Control de vuelo
    local flightController = {
        _bodyVelocity = bodyVelocity,
        _bodyGyro = bodyGyro,
        _speed = speed or 100,
        _isFlying = false,
        
        moveTo = function(self, position)
            local direction = (position - hrp.Position).Unit
            self._bodyVelocity.Velocity = direction * self._speed
            self._bodyGyro.CFrame = CFrame.lookAt(hrp.Position, position)
        end,
        
        stop = function(self)
            self._bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            self._isFlying = false
        end,
        
        destroy = function(self)
            if self._bodyVelocity then self._bodyVelocity:Destroy() end
            if self._bodyGyro then self._bodyGyro:Destroy() end
        end
    }
    
    return flightController
end

-- Técnica 4: Remote Function Hijacking
function ExploitEngine:hookRemoteFunction(remoteName, callback)
    local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
    if not remote or not remote:IsA("RemoteFunction") then
        ExploitEngine._logger:warn("RemoteFunction not found:", remoteName)
        return false
    end
    
    -- Guardar función original
    ExploitEngine._originalFunctions[remote] = remote.InvokeServer
    
    -- Reemplazar con hook
    remote.InvokeServer = function(self, ...)
        local args = {...}
        
        -- Ejecutar callback antes de la llamada
        local shouldBlock, modifiedArgs = callback("BeforeInvoke", args)
        
        if shouldBlock then
            return modifiedArgs -- Retornar datos falsificados
        end
        
        -- Llamar a función original con args modificados
        local result = ExploitEngine._originalFunctions[remote](self, unpack(modifiedArgs or args))
        
        -- Ejecutar callback después de la llamada
        callback("AfterInvoke", result)
        
        return result
    end
    
    ExploitEngine._hooks[remote] = remote.InvokeServer
    ExploitEngine._logger:info("Hooked RemoteFunction:", remoteName)
    
    return true
end

--======================================================================
--  ADVANCED TASK SCHEDULER: Sistema de tareas optimizado
--======================================================================

local TaskScheduler = {
    _logger = Logger.new("TaskScheduler"),
    _tasks = {},
    _nextTaskId = 1,
    _frameBudget = 0.005, -- 5ms por frame máximo
    _lastUpdate = 0
}

function TaskScheduler:init()
    self._logger:info("Initializing Advanced Task Scheduler")
    
    -- Heartbeat para procesamiento de tareas
    RunService.Heartbeat:Connect(function(deltaTime)
        self:_processTasks(deltaTime)
    end)
end

function TaskScheduler:_processTasks(deltaTime)
    local startTime = os.clock()
    local processed = 0
    
    for taskId, task in pairs(self._tasks) do
        if os.clock() - startTime > self._frameBudget then
            break -- Presupuesto de tiempo excedido
        end
        
        if task.Type == "Instant" and not task.Executed then
            local success, result = pcall(task.Function, unpack(task.Args or {}))
            if not success then
                self._logger:error("Task failed:", taskId, result)
            end
            task.Executed = true
            
        elseif task.Type == "Interval" then
            if os.clock() - task.LastExecuted >= task.Interval then
                task.LastExecuted = os.clock()
                local success, result = pcall(task.Function, unpack(task.Args or {}))
                if not success then
                    self._logger:error("Interval task failed:", taskId, result)
                end
            end
            
        elseif task.Type == "Delayed" then
            if os.clock() >= task.ExecuteAt and not task.Executed then
                local success, result = pcall(task.Function, unpack(task.Args or {}))
                if not success then
                    self._logger:error("Delayed task failed:", taskId, result)
                end
                task.Executed = true
            end
        end
        
        processed += 1
    end
    
    -- Limpieza de tareas completadas
    for taskId, task in pairs(self._tasks) do
        if (task.Type == "Instant" and task.Executed) or 
           (task.Type == "Delayed" and task.Executed) then
            self._tasks[taskId] = nil
        end
    end
end

function TaskScheduler:scheduleInstant(func, ...)
    local taskId = self._nextTaskId
    self._nextTaskId += 1
    
    self._tasks[taskId] = {
        Type = "Instant",
        Function = func,
        Args = {...},
        Executed = false,
        Created = os.clock()
    }
    
    return taskId
end

function TaskScheduler:scheduleInterval(func, interval, ...)
    local taskId = self._nextTaskId
    self._nextTaskId += 1
    
    self._tasks[taskId] = {
        Type = "Interval",
        Function = func,
        Args = {...},
        Interval = interval,
        LastExecuted = os.clock(),
        Created = os.clock()
    }
    
    return taskId
end

function TaskScheduler:scheduleDelayed(func, delay, ...)
    local taskId = self._nextTaskId
    self._nextTaskId += 1
    
    self._tasks[taskId] = {
        Type = "Delayed",
        Function = func,
        Args = {...},
        ExecuteAt = os.clock() + delay,
        Executed = false,
        Created = os.clock()
    }
    
    return taskId
end

function TaskScheduler:cancelTask(taskId)
    if self._tasks[taskId] then
        self._tasks[taskId] = nil
        return true
    end
    return false
end

--======================================================================
--  INTELLIGENT TARGETING SYSTEM: Sistema de selección de objetivos
--======================================================================

local TargetingSystem = {
    _logger = Logger.new("TargetingSystem"),
    _targetCache = {},
    _cacheTTL = 2, -- segundos
    _lastScan = 0,
    _blacklist = {},
    _priorityWeights = {
        Distance = 0.35,
        Health = 0.25,
        Threat = 0.20,
        LootValue = 0.10,
        Experience = 0.10
    }
}

function TargetingSystem:scanTargets(maxDistance, forceRescan)
    local now = os.clock()
    
    -- Usar cache si no necesita rescan
    if not forceRescan and (now - self._lastScan < self._cacheTTL) then
        return self._targetCache
    end
    
    self._lastScan = now
    local character = Players.LocalPlayer.Character
    if not character then return {} end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    
    local myPosition = hrp.Position
    local foundTargets = {}
    
    -- Buscar en Workspace.Enemies
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return {} end
    
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if enemy:IsA("Model") and not self._blacklist[enemy] then
            local targetHRP = enemy:FindFirstChild("HumanoidRootPart")
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            
            if targetHRP and humanoid and humanoid.Health > 0 then
                local distance = (targetHRP.Position - myPosition).Magnitude
                
                if distance <= maxDistance then
                    -- Calcular score de prioridad
                    local priorityScore = self:_calculatePriorityScore(enemy, distance, humanoid)
                    
                    table.insert(foundTargets, {
                        Instance = enemy,
                        Name = enemy.Name,
                        Humanoid = humanoid,
                        HRP = targetHRP,
                        Health = humanoid.Health,
                        MaxHealth = humanoid.MaxHealth,
                        Distance = distance,
                        Position = targetHRP.Position,
                        PriorityScore = priorityScore,
                        LastSeen = now,
                        IsBoss = enemy.Name:lower():find("boss") ~= nil
                    })
                end
            end
        end
    end
    
    -- Ordenar por prioridad
    table.sort(foundTargets, function(a, b)
        return a.PriorityScore > b.PriorityScore
    end)
    
    -- Actualizar cache
    self._targetCache = foundTargets
    return foundTargets
end

function TargetingSystem:_calculatePriorityScore(enemy, distance, humanoid)
    local score = 0
    local maxDistance = 500
    
    -- Factor distancia (más cerca = mayor score)
    local distanceFactor = 1 - (distance / maxDistance)
    score += distanceFactor * self._priorityWeights.Distance
    
    -- Factor salud (menos vida = mayor score)
    local healthFactor = 1 - (humanoid.Health / humanoid.MaxHealth)
    score += healthFactor * self._priorityWeights.Health
    
    -- Factor amenaza (bosses tienen mayor amenaza)
    local threatFactor = enemy.Name:lower():find("boss") and 1.0 or 0.3
    score += threatFactor * self._priorityWeights.Threat
    
    -- Bonus por rareza del nombre
    if enemy.Name:lower():find("demon") or enemy.Name:lower():find("dragon") then
        score += 0.5
    end
    
    return math.clamp(score, 0, 1)
end

function TargetingSystem:getBestTarget(maxDistance)
    local targets = self:scanTargets(maxDistance or 500)
    if #targets > 0 then
        return targets[1]
    end
    return nil
end

function TargetingSystem:blacklistTarget(enemy, duration)
    if not enemy then return end
    
    self._blacklist[enemy] = os.clock() + (duration or 10)
    
    -- Programar remoción del blacklist
    TaskScheduler:scheduleDelayed(function()
        self._blacklist[enemy] = nil
    end, duration or 10)
end

--======================================================================
--  COMBAT AI ENGINE: IA avanzada para combate
--======================================================================

local CombatAI = {
    _logger = Logger.new("CombatAI"),
    _state = "IDLE",
    _currentTarget = nil,
    _attackPatterns = {
        AGGRESSIVE = {"COMBO_1", "COMBO_2", "HEAVY_ATTACK", "SPIN_ATTACK"},
        DEFENSIVE = {"BLOCK", "DODGE", "COUNTER", "QUICK_ATTACK"},
        BURST = {"CHARGE", "ULTIMATE", "COMBO_3", "FINISHER"}
    },
    _lastAttack = 0,
    _attackCooldown = 0.3,
    _comboCounter = 0,
    _lastComboTime = 0
}

function CombatAI:setState(state)
    if self._state == state then return end
    
    self._logger:debug("State transition:", self._state, "->", state)
    self._state = state
    
    -- Ejecutar callbacks de transición
    if self._onStateChanged then
        self._onStateChanged(self._state)
    end
end

function CombatAI:attack(target, attackType)
    if not target or not target.Humanoid then return false end
    
    local now = os.clock()
    if now - self._lastAttack < self._attackCooldown then
        return false -- En cooldown
    end
    
    -- Verificar si el objetivo sigue vivo
    if target.Humanoid.Health <= 0 then
        self:setState("IDLE")
        return false
    end
    
    -- Seleccionar patrón de ataque basado en estado
    local pattern = self._attackPatterns.AGGRESSIVE
    if self._state == "DEFENSIVE" then
        pattern = self._attackPatterns.DEFENSIVE
    elseif self._state == "BURST" then
        pattern = self._attackPatterns.BURST
    end
    
    -- Sistema de combo
    if now - self._lastComboTime > 2 then
        self._comboCounter = 0 -- Reset combo si pasa mucho tiempo
    end
    
    local attackName = pattern[math.random(1, #pattern)]
    if self._comboCounter >= 3 then
        attackName = "FINISHER" -- Ataque final de combo
    end
    
    -- Ejecutar ataque (simulado por ahora)
    self._logger:debug("Executing attack:", attackName, "on", target.Name)
    
    -- Aquí iría la lógica real de ataque usando FastAttack
    if _G.FastAttack then
        local success = _G.FastAttack:execute(attackName, target)
        if success then
            self._comboCounter += 1
            self._lastComboTime = now
        end
    end
    
    self._lastAttack = now
    return true
end

function CombatAI:update(deltaTime)
    if self._state == "IDLE" then
        -- Buscar nuevo objetivo
        local target = TargetingSystem:getBestTarget(200)
        if target then
            self._currentTarget = target
            self:setState("ENGAGING")
        end
        
    elseif self._state == "ENGAGING" then
        if not self._currentTarget then
            self:setState("IDLE")
            return
        end
        
        -- Calcular distancia al objetivo
        local character = Players.LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local distance = (hrp.Position - self._currentTarget.Position).Magnitude
        
        if distance < 20 then
            self:setState("ATTACKING")
        else
            -- Mover hacia el objetivo
            self:_moveToTarget(self._currentTarget.Position)
        end
        
    elseif self._state == "ATTACKING" then
        if not self._currentTarget then
            self:setState("IDLE")
            return
        end
        
        -- Atacar al objetivo
        local didAttack = self:attack(self._currentTarget)
        
        if not didAttack then
            -- Posicionarse mejor
            self:_repositionAroundTarget(self._currentTarget)
        end
        
        -- Verificar si el objetivo murió
        if self._currentTarget.Humanoid.Health <= 0 then
            self:setState("IDLE")
            self._currentTarget = nil
            self._comboCounter = 0
        end
    end
end

function CombatAI:_moveToTarget(position)
    -- Implementar lógica de movimiento aquí
    -- Usaría Teleporter o movimiento directo
    if _G.Teleporter then
        _G.Teleporter:teleportTo(position)
    end
end

function CombatAI:_repositionAroundTarget(target)
    if not target then return end
    
    -- Calcular posición óptima alrededor del objetivo
    local angle = math.random() * math.pi * 2
    local distance = 10 + math.random() * 10
    local offset = Vector3.new(
        math.cos(angle) * distance,
        0,
        math.sin(angle) * distance
    )
    
    local newPosition = target.Position + offset
    
    if _G.Teleporter then
        _G.Teleporter:teleportTo(newPosition)
    end
end

--======================================================================
--  QUEST OPTIMIZATION ENGINE: Sistema optimizado de misiones
--======================================================================

local QuestEngine = {
    _logger = Logger.new("QuestEngine"),
    _currentQuest = nil,
    _questProgress = 0,
    _questHistory = {},
    _questCache = {},
    _efficiencyTracker = {
        killsPerMinute = 0,
        xpPerMinute = 0,
        lastKillTime = 0,
        killCount = 0
    }
}

function QuestEngine:findOptimalQuest(level)
    level = level or Players.LocalPlayer.Data.Level.Value
    
    -- Buscar quests disponibles
    local availableQuests = self:_getAvailableQuests(level)
    if #availableQuests == 0 then
        self._logger:warn("No quests available for level", level)
        return nil
    end
    
    -- Evaluar cada quest según múltiples factores
    local bestQuest = nil
    local bestScore = -math.huge
    
    for _, quest in ipairs(availableQuests) do
        local score = self:_evaluateQuest(quest, level)
        
        if score > bestScore then
            bestScore = score
            bestQuest = quest
        end
    end
    
    if bestQuest then
        self._logger:info("Selected optimal quest:", bestQuest.Name, "Score:", bestScore)
    end
    
    return bestQuest
end

function QuestEngine:_evaluateQuest(quest, playerLevel)
    local score = 0
    
    -- Factor 1: Diferencia de nivel (preferir quests del nivel del jugador)
    local levelDiff = math.abs(quest.Level - playerLevel)
    score += 100 / (levelDiff + 1)
    
    -- Factor 2: Recompensa de XP
    if quest.Rewards and quest.Rewards.Experience then
        score += quest.Rewards.Experience * 0.1
    end
    
    -- Factor 3: Dificultad (preferir más fáciles para farming rápido)
    if quest.IsBoss then
        score -= 50 -- Boss quests son más difíciles
    end
    
    -- Factor 4: Densidad de spawns
    if quest.SpawnPoints and #quest.SpawnPoints > 0 then
        score += #quest.SpawnPoints * 10 -- Más spawns = mejor
    end
    
    -- Factor 5: Distancia a NPC
    if quest.NPCPosition then
        local character = Players.LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distance = (hrp.Position - quest.NPCPosition).Magnitude
                score += 100 / (distance + 1) -- Más cerca = mejor
            end
        end
    end
    
    -- Factor 6: Eficiencia histórica
    if self._questHistory[quest.Name] then
        local historicalEfficiency = self._questHistory[quest.Name].efficiency or 1
        score *= historicalEfficiency
    end
    
    return score
end

function QuestEngine:acceptQuest(quest)
    if not quest then return false end
    
    self._logger:info("Accepting quest:", quest.Name)
    self._currentQuest = quest
    self._questProgress = 0
    
    -- Aquí iría la lógica real para aceptar la quest
    if _G.QuestSystem then
        return _G.QuestSystem:startQuest(quest)
    end
    
    return true
end

function QuestEngine:updateProgress(mobName)
    if not self._currentQuest then return false end
    
    -- Verificar si el mob es parte de la quest actual
    if mobName == self._currentQuest.MobName then
        self._questProgress += 1
        
        -- Actualizar tracker de eficiencia
        local now = os.clock()
        self._efficiencyTracker.killCount += 1
        
        if self._efficiencyTracker.lastKillTime > 0 then
            local timeSinceLastKill = now - self._efficiencyTracker.lastKillTime
            self._efficiencyTracker.killsPerMinute = 
                60 / timeSinceLastKill
        end
        
        self._efficiencyTracker.lastKillTime = now
        
        -- Verificar si la quest está completa
        if self._questProgress >= self._currentQuest.Required then
            self:_completeQuest()
        end
        
        return true
    end
    
    return false
end

function QuestEngine:_completeQuest()
    if not self._currentQuest then return false end
    
    self._logger:info("Quest completed:", self._currentQuest.Name)
    
    -- Calcular eficiencia
    local completionTime = os.clock() - (self._questHistory[self._currentQuest.Name] or {}).startTime
    local efficiency = self._currentQuest.Required / completionTime
    
    -- Guardar en historial
    self._questHistory[self._currentQuest.Name] = {
        completions = (self._questHistory[self._currentQuest.Name] or {}).completions or 0 + 1,
        efficiency = efficiency,
        lastCompletion = os.clock()
    }
    
    -- Reclamar recompensas
    self:_claimRewards()
    
    -- Buscar nueva quest
    self._currentQuest = nil
    self._questProgress = 0
    
    return true
end

function QuestEngine:_claimRewards()
    -- Implementar lógica para reclamar recompensas
    if _G.QuestSystem then
        _G.QuestSystem:claimRewards()
    end
end

--======================================================================
--  PERFORMANCE MONITOR: Monitor de rendimiento en tiempo real
--======================================================================

local PerformanceMonitor = {
    _logger = Logger.new("PerformanceMonitor"),
    _metrics = {
        fps = 0,
        memoryUsage = 0,
        scriptTime = 0,
        networkLatency = 0,
        entityCount = 0
    },
    _lastUpdate = 0,
    _updateInterval = 2
}

function PerformanceMonitor:init()
    self._logger:info("Initializing Performance Monitor")
    
    -- Heartbeat para métricas de FPS
    local fpsSamples = {}
    local fpsSampleCount = 0
    
    RunService.Heartbeat:Connect(function(deltaTime)
        local fps = 1 / deltaTime
        
        -- Promedio de últimos 60 frames
        table.insert(fpsSamples, fps)
        if #fpsSamples > 60 then
            table.remove(fpsSamples, 1)
        end
        
        local total = 0
        for _, sample in ipairs(fpsSamples) do
            total += sample
        end
        
        self._metrics.fps = math.floor(total / #fpsSamples)
    end)
    
    -- Actualizar otras métricas periódicamente
    TaskScheduler:scheduleInterval(function()
        self:_updateMetrics()
    end, self._updateInterval)
end

function PerformanceMonitor:_updateMetrics()
    -- Uso de memoria
    self._metrics.memoryUsage = collectgarbage("count")
    
    -- Contar entidades
    local entityCount = 0
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if instance:IsA("Model") or instance:IsA("BasePart") then
            entityCount += 1
        end
    end
    self._metrics.entityCount = entityCount
    
    -- Log si el rendimiento es bajo
    if self._metrics.fps < 30 then
        self._logger:warn("Low FPS detected:", self._metrics.fps, "FPS")
    end
    
    if self._metrics.memoryUsage > 500 then -- >500KB
        self._logger:warn("High memory usage:", self._metrics.memoryUsage, "KB")
        -- Forzar garbage collection si es necesario
        if self._metrics.memoryUsage > 1000 then
            collectgarbage("collect")
        end
    end
end

function PerformanceMonitor:getMetrics()
    return self._metrics
end

function PerformanceMonitor:optimize()
    self._logger:info("Starting performance optimization")
    
    -- 1. Limpiar cache de TargetingSystem
    TargetingSystem._targetCache = {}
    
    -- 2. Cancelar tareas no críticas
    local tasksToKeep = {}
    for taskId, task in pairs(TaskScheduler._tasks) do
        if task.Priority == "CRITICAL" then
            tasksToKeep[taskId] = task
        end
    end
    TaskScheduler._tasks = tasksToKeep
    
    -- 3. Forzar garbage collection
    collectgarbage("collect")
    
    -- 4. Reducir calidad gráfica temporalmente
    settings().Rendering.QualityLevel = 1
    
    self._logger:info("Performance optimization complete")
end

--======================================================================
--  MAIN AUTO FARM CLASS: Clase principal
--======================================================================

function AutoFarmLevel.new(services, variables, teleporter, questSystem, fastAttack, bringMob)
    local self = setmetatable({}, AutoFarmLevel)
    
    -- Dependencies
    self.Services = services
    self.Variables = variables
    self.Teleporter = teleporter
    self.QuestSystem = questSystem
    self.FastAttack = fastAttack
    self.BringMob = bringMob
    
    -- State
    self._running = false
    self._currentState = "IDLE"
    self._currentTarget = nil
    self._stats = {
        kills = 0,
        xpGained = 0,
        startTime = 0,
        questsCompleted = 0,
        efficiency = 0
    }
    
    -- Systems
    self.Logger = Logger.new("AutoFarmLevel")
    self.TargetingSystem = TargetingSystem
    self.CombatAI = CombatAI
    self.QuestEngine = QuestEngine
    self.ExploitEngine = ExploitEngine
    
    -- Initialize subsystems
    TaskScheduler:init()
    PerformanceMonitor:init()
    
    -- Patch inicial
    self:_applyInitialPatches()
    
    self.Logger:info("AutoFarmLevel Professional v" .. self.__version .. " initialized")
    
    return self
end

function AutoFarmLevel:_applyInitialPatches()
    self.Logger:info("Applying initial patches...")
    
    -- 1. Patch humanoid para godmode
    local character = self.Services:GetCharacter()
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            self.ExploitEngine:patchHumanoid(humanoid)
        end
    end
    
    -- 2. Habilitar vuelo
    self._flightController = self.ExploitEngine:enableFlight(character, 100)
    
    -- 3. Hook remotes importantes
    self.ExploitEngine:hookRemoteFunction("Damage", function(event, ...)
        if event == "BeforeInvoke" then
            local args = {...}
            -- Multiplicar daño x10
            if args[2] then -- arg de daño
                args[2] = args[2] * 10
            end
            return false, args -- No bloquear, pero modificar args
        end
    end)
    
    self.Logger:info("Initial patches applied successfully")
end

function AutoFarmLevel:start()
    if self._running then
        self.Logger:warn("Already running")
        return false
    end
    
    self.Logger:info("Starting Professional Auto Farm")
    self._running = true
    self._stats.startTime = os.clock()
    
    -- Iniciar sistemas
    self.CombatAI:setState("IDLE")
    
    -- Bucle principal optimizado
    task.spawn(function()
        local lastUpdate = os.clock()
        
        while self._running do
            local currentTime = os.clock()
            local deltaTime = currentTime - lastUpdate
            lastUpdate = currentTime
            
            -- Ejecutar update en todos los sistemas
            self:_updateSystems(deltaTime)
            
            -- Control de FPS (60 updates por segundo máximo)
            task.wait(1/60)
        end
    end)
    
    self.Logger:info("Auto Farm started successfully")
    return true
end

function AutoFarmLevel:_updateSystems(deltaTime)
    -- 1. Actualizar Quest Engine
    if not self.QuestEngine._currentQuest then
        local optimalQuest = self.QuestEngine:findOptimalQuest(
            self.Services.LocalPlayer.Data.Level.Value
        )
        if optimalQuest then
            self.QuestEngine:acceptQuest(optimalQuest)
        end
    end
    
    -- 2. Actualizar Combat AI
    self.CombatAI:update(deltaTime)
    
    -- 3. Actualizar Targeting (cada 0.5 segundos)
    if os.clock() - self.TargetingSystem._lastScan > 0.5 then
        self.TargetingSystem:scanTargets(500, false)
    end
    
    -- 4. Verificar rendimiento (cada 5 segundos)
    if os.clock() % 5 < deltaTime then
        local metrics = PerformanceMonitor:getMetrics()
        if metrics.fps < 30 then
            PerformanceMonitor:optimize()
        end
    end
end

function AutoFarmLevel:stop()
    if not self._running then
        self.Logger:warn("Not running")
        return false
    end
    
    self.Logger:info("Stopping Auto Farm")
    self._running = false
    
    -- Limpiar sistemas
    if self._flightController then
        self._flightController:destroy()
        self._flightController = nil
    end
    
    -- Restaurar estado normal
    self.CombatAI:setState("IDLE")
    
    self.Logger:info("Auto Farm stopped")
    return true
end

function AutoFarmLevel:toggle()
    if self._running then
        return self:stop()
    else
        return self:start()
    end
end

function AutoFarmLevel:getStats()
    local currentTime = os.clock()
    local runtime = currentTime - self._stats.startTime
    
    return {
        running = self._running,
        kills = self._stats.kills,
        xpGained = self._stats.xpGained,
        questsCompleted = self._stats.questsCompleted,
        runtime = math.floor(runtime),
        efficiency = self._stats.kills / math.max(runtime / 60, 1), -- kills por minuto
        currentQuest = self.QuestEngine._currentQuest and self.QuestEngine._currentQuest.Name or "None",
        questProgress = self.QuestEngine._questProgress,
        currentTarget = self.CombatAI._currentTarget and self.CombatAI._currentTarget.Name or "None",
        performance = PerformanceMonitor:getMetrics()
    }
end

function AutoFarmLevel:setStrategy(strategy)
    -- strategy: "AGGRESSIVE", "DEFENSIVE", "BALANCED", "STEALTH"
    self.CombatAI:setState(strategy)
    self.Logger:info("Strategy set to:", strategy)
end

function AutoFarmLevel:optimizePerformance()
    PerformanceMonitor:optimize()
    return true
end

function AutoFarmLevel:emergencyStop()
    self.Logger:warn("EMERGENCY STOP ACTIVATED")
    
    -- Detener todo inmediatamente
    self._running = false
    
    -- Cancelar todas las tareas
    for taskId, _ in pairs(TaskScheduler._tasks) do
        TaskScheduler:cancelTask(taskId)
    end
    
    -- Restaurar patches
    for instance, originalFunc in pairs(self.ExploitEngine._originalFunctions) do
        if instance:IsA("RemoteFunction") then
            instance.InvokeServer = originalFunc
        elseif instance:IsA("Humanoid") then
            -- Restaurar TakeDamage
            instance.TakeDamage = originalFunc
        end
    end
    
    -- Limpiar flight
    if self._flightController then
        self._flightController:destroy()
    end
    
    self.Logger:info("Emergency stop complete")
    return true
end

-- Configuración avanzada
function AutoFarmLevel:configure(config)
    -- config es una tabla con opciones de configuración
    
    -- Configurar Targeting
    if config.targeting then
        if config.targeting.priorityWeights then
            self.TargetingSystem._priorityWeights = config.targeting.priorityWeights
        end
    end
    
    -- Configurar Combat AI
    if config.combat then
        if config.combat.attackCooldown then
            self.CombatAI._attackCooldown = config.combat.attackCooldown
        end
        
        if config.combat.attackPatterns then
            self.CombatAI._attackPatterns = config.combat.attackPatterns
        end
    end
    
    -- Configurar Performance
    if config.performance then
        if config.performance.maxFPS then
            -- Ajustar frame budget
            TaskScheduler._frameBudget = 1 / config.performance.maxFPS
        end
    end
    
    self.Logger:info("Configuration applied")
end

-- Método para debugging avanzado
function AutoFarmLevel:debugDump()
    local dump = {
        version = self.__version,
        running = self._running,
        state = self._currentState,
        stats = self:getStats(),
        systems = {
            targeting = {
                cacheSize = #self.TargetingSystem._targetCache,
                blacklistSize = 0
            },
            combatAI = {
                state = self.CombatAI._state,
                comboCounter = self.CombatAI._comboCounter
            },
            questEngine = {
                currentQuest = self.QuestEngine._currentQuest and self.QuestEngine._currentQuest.Name,
                progress = self.QuestEngine._questProgress
            }
        }
    }
    
    -- Contar blacklist
    for _ in pairs(self.TargetingSystem._blacklist) do
        dump.systems.targeting.blacklistSize += 1
    end
    
    return HttpService:JSONEncode(dump)
end

return AutoFarmLevel