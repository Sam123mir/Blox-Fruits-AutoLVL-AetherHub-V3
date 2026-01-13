--[[
    AETHER HUB - PROFESSIONAL QUEST SYSTEM v4.1
    ============================================================================
    Sistema inteligente de gestión de misiones para Blox Fruits.
    Optimizado para Sea 1, 2 y 3 con detección proactiva y caching de spawns.
    
    INGENIERÍA:
    - Intelligent Spawn Caching (Optimized lookup)
    - Proactive Quest Detection (Level sync)
    - Safe Remote Invocation via Services common wrapper
    - Modular database para Sea-specific logic
]]

local QuestSystem = {}
QuestSystem.__index = QuestSystem

--// Constants
local SPECIAL_MOBS = {
    ["Fishman Warrior"] = {Level = 375, Entry = Vector3.new(61163.8, 11.6, 1819.7)},
    ["Fishman Commando"] = {Level = 400, Entry = Vector3.new(61163.8, 11.6, 1819.7)}
}

--[[
    CONSTRUCTOR
]]
function QuestSystem.new(services, variables)
    local self = setmetatable({}, QuestSystem)
    
    self._services = services or error("[QUESTSYSTEM] Services required")
    self._vars = variables or error("[QUESTSYSTEM] Variables required")
    
    -- State
    self._currentQuestData = nil
    self._spawnCache = {}
    self._isCaching = false
    
    self:_initialize()
    
    print("[QUESTSYSTEM] Professional Module Initialized")
    return self
end

--[[
    PRIVATE: Initial setup and cache building
]]
function QuestSystem:_initialize()
    task.spawn(function()
        self:RefreshCache()
    end)
end

--[[
    PUBLIC: Refresh the mob spawn cache
]]
function QuestSystem:RefreshCache()
    if self._isCaching then return end
    self._isCaching = true
    
    table.clear(self._spawnCache)
    
    -- Efficient scanning of workspace
    local enemies = workspace:FindFirstChild("Enemies")
    local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
    
    local function process(instance)
        if instance:IsA("Model") and instance:FindFirstChild("HumanoidRootPart") then
            local cleanName = self:CleanName(instance.Name)
            if not self._spawnCache[cleanName] then
                self._spawnCache[cleanName] = instance.HumanoidRootPart.CFrame
            end
        elseif instance:IsA("Part") and instance.Parent.Name == "EnemySpawns" then
            local cleanName = self:CleanName(instance.Name)
            self._spawnCache[cleanName] = instance.CFrame
        end
    end
    
    if enemies then
        for _, mob in ipairs(enemies:GetChildren()) do process(mob) end
    end
    
    if worldOrigin then
        local spawns = worldOrigin:FindFirstChild("EnemySpawns")
        if spawns then
            for _, s in ipairs(spawns:GetChildren()) do process(s) end
        end
    end
    
    self._isCaching = false
    print(string.format("[QUESTSYSTEM] Spawn cache updated (%d entries)", self:_countCache()))
end

--[[
    PUBLIC: Get current optimal quest based on level
]]
function QuestSystem:GetCurrentQuest()
    local level = self._services.LocalPlayer.Data.Level.Value
    
    -- Cache lookup for efficiency
    if self._currentQuestData and level >= self._currentQuestData.LevelReq then
        -- Validar si seguimos en el mismo rango de quest (Blox Fruits logic)
        -- Si subimos mucho de nivel, forzar re-detección
        if level < (self._currentQuestData.LevelReq + 50) then
            return self._currentQuestData
        end
    end
    
    -- Proactive detection via game modules
    self._currentQuestData = self:_detectQuest(level)
    return self._currentQuestData
end

--[[
    PRIVATE: Internal quest detection logic
]]
function QuestSystem:_detectQuest(level: number)
    local success, questData = pcall(function()
        local guide = require(game:GetService("ReplicatedStorage").GuideModule)
        local quests = require(game:GetService("ReplicatedStorage").Quests)
        
        local bestNpc, bestLevel = nil, 0
        
        -- Encontrar el mejor NPC para el nivel actual
        for npc, data in pairs(guide.Data.NPCList) do
            for _, reqLevel in pairs(data.Levels) do
                if level >= reqLevel and reqLevel >= bestLevel then
                    bestNpc = npc
                    bestLevel = reqLevel
                end
            end
        end
        
        if bestNpc and bestLevel > 0 then
            -- Mappear con el nombre de la quest
            for qName, qData in pairs(quests) do
                for qIndex, qInfo in pairs(qData) do
                    if qInfo.LevelReq == bestLevel then
                        local mobName = next(qInfo.Task)
                        return {
                            QuestName = qName,
                            QuestIndex = qIndex,
                            LevelReq = bestLevel,
                            MobName = mobName,
                            NpcCFrame = bestNpc.CFrame,
                            MobBaseName = self:CleanName(mobName)
                        }
                    end
                end
            end
        end
    end)
    
    return success and questData or nil
end

--[[
    PUBLIC: Execute StartQuest remote
]]
function QuestSystem:StartQuest()
    local quest = self:GetCurrentQuest()
    if not quest then return false end
    
    -- Usar InvokeCommF profesional con reintentos
    local success, err = self._services:InvokeCommF("StartQuest", quest.QuestName, quest.QuestIndex)
    if success then
        print(string.format("[QUESTSYSTEM] Accepted: %s", quest.QuestName))
    end
    return success, err
end

--[[
    PUBLIC: Check if a quest is currently active
]]
function QuestSystem:IsQuestActive()
    local playerGui = self._services.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local main = playerGui:FindFirstChild("Main")
        if main then
            local questGui = main:FindFirstChild("Quest")
            return questGui and questGui.Visible
        end
    end
    return false
end

--[[
    UTIL: Clean mob names from level suffixes
]]
function QuestSystem:CleanName(name: string)
    local cleaned = name:gsub(" %[%Lv%. %d+%]% ", ""):gsub(" %[%Lv%. %d+%] ", ""):gsub(" %[%d+%] ", "")
    return cleaned:gsub("%s+", "")
end

function QuestSystem:_countCache()
    local count = 0
    for _ in pairs(self._spawnCache) do count += 1 end
    return count
end

return QuestSystem