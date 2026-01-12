--[[
    ================================================================
         AETHER HUB - Quest System (v3.0)
    ================================================================
    
    ADVANCED QUEST DETECTION & MANAGEMENT:
    ✓ Auto quest detection based on player level
    ✓ GuideModule integration
    ✓ Quest verification
    ✓ Mob spawn location caching
    ✓ Special handling for Sea 2/3
    
    BASED ON: Silver Hub Quest System
    DEPENDENCIES: Services
]]

--// MODULE
local QuestSystem = {}
QuestSystem.__index = QuestSystem

--// DEPENDENCIES
local Services = nil

--// PRIVATE STATE
local _currentQuest = nil
local _mobSpawnCache = {}
local _questCache = {}

--// CONSTANTS
local SPECIAL_MOBS = {
    ["Fishman Warrior"] = {
        Level = 375,
        RequiresEntry = true,
        EntryVector = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)
    },
    ["Fishman Commando"] = {
        Level = 400,
        RequiresEntry = true,
        EntryVector = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)
    }
}

--[[
    Constructor
    @param services table
]]
function QuestSystem.new(services)
    local self = setmetatable({}, QuestSystem)
    
    Services = services or error("[QUESTSYSTEM] Services required")
    
    -- Build mob spawn cache
    self:_buildMobSpawnCache()
    
    return self
end

--[[
    PRIVATE: Build mob spawn location cache
]]
function QuestSystem:_buildMobSpawnCache()
    print("[QUESTSYSTEM] Building mob spawn cache...")
    
    -- Create folder for cached spawns
    local enemySpawnsFolder = Services.Workspace:FindFirstChild("EnemySpawns")
    if not enemySpawnsFolder then
        enemySpawnsFolder = Instance.new("Folder")
        enemySpawnsFolder.Name = "EnemySpawns"
        enemySpawnsFolder.Parent = Services.Workspace
    end
    
    -- Cache from WorldOrigin
    local worldOrigin = Services.Workspace:FindFirstChild("_WorldOrigin")
    if worldOrigin then
        local enemySpawns = worldOrigin:FindFirstChild("EnemySpawns")
        if enemySpawns then
            for _, spawn in ipairs(enemySpawns:GetChildren()) do
                if spawn:IsA("Part") then
                    self:_processMobSpawn(spawn, enemySpawnsFolder)
                end
            end
        end
    end
    
    -- Cache from active enemies
    for _, enemy in ipairs(Services.Workspace.Enemies:GetChildren()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
            self:_processMobSpawn(enemy.HumanoidRootPart, enemySpawnsFolder, enemy.Name)
        end
    end
    
    -- Cache from ReplicatedStorage
    for _, model in ipairs(game.ReplicatedStorage:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
            self:_processMobSpawn(model.HumanoidRootPart, enemySpawnsFolder, model.Name)
        end
    end
    
    print(string.format("[QUESTSYSTEM] Cached %d mob spawn locations", #enemySpawnsFolder:GetChildren()))
end

--[[
    PRIVATE: Process and cache mob spawn
    @param part BasePart
    @param folder Folder
    @param name string?
]]
function QuestSystem:_processMobSpawn(part, folder, name)
    if not part or not part:IsA("BasePart") then return end
    
    -- Clean mob name
    local mobName = name or part.Name
    local cleanName = self:_cleanMobName(mobName)
    
    -- Check if already exists
    if folder:FindFirstChild(cleanName) then return end
    
    -- Create cached spawn point
    local spawnPoint = part:Clone()
    spawnPoint.Name = cleanName
    spawnPoint.Anchored = true
    spawnPoint.Transparency = 1
    spawnPoint.CanCollide = false
    spawnPoint.Parent = folder
    
    -- Store in cache
    if not _mobSpawnCache[cleanName] then
        _mobSpawnCache[cleanName] = {}
    end
    
    table.insert(_mobSpawnCache[cleanName], spawnPoint.CFrame)
end

--[[
    PRIVATE: Clean mob name (remove level, brackets)
    @param name string
    @return string
]]
function QuestSystem:_cleanMobName(name)
    local cleaned = name
    cleaned = string.gsub(cleaned, "Lv%. ", "")
    cleaned = string.gsub(cleaned, "[%[%]]", "")
    cleaned = string.gsub(cleaned, "%d+", "")
    cleaned = string.gsub(cleaned, "%s+", "")
    return cleaned
end

--[[
    PUBLIC: Get quest information for current level
    @return table - Quest data
]]
function QuestSystem:GetCurrentQuest()
    local level = Services.LocalPlayer.Data.Level.Value
    
    -- Check cache
    if _currentQuest and _currentQuest.LevelRange then
        local min, max = _currentQuest.LevelRange[1], _currentQuest.LevelRange[2]
        if level >= min and level <= max then
            return _currentQuest
        end
    end
    
    -- Get quest from GuideModule and Quests
    local questData = self:_detectQuest(level)
    
    if questData then
        _currentQuest = questData
        return questData
    end
    
    return nil
end

--[[
    PRIVATE: Detect quest based on level
    @param level number
    @return table?
]]
function QuestSystem:_detectQuest(level)
    -- Early game quests
    if level >= 1 and level <= 9 then
        return self:_getEarlyQuest(level)
    end
    
    -- Special handling for specific levels
    if level >= 375 and level <= 449 then
        return self:_getFishmanQuest(level)
    end
    
    -- Load from game modules
    local guideModule = self:_getGuideModule()
    local questsModule = self:_getQuestsModule()
    
    if not guideModule or not questsModule then
        warn("[QUESTSYSTEM] Failed to load game modules")
        return nil
    end
    
    -- Find appropriate quest
    local questData = self:_findQuestInModules(level, guideModule, questsModule)
    
    return questData
end

--[[
    PRIVATE: Get early game quest (Level 1-9)
    @param level number
    @return table
]]
function QuestSystem:_getEarlyQuest(level)
    local team = tostring(Services.LocalPlayer.Team)
    
    if team == "Marines" then
        return {
            QuestName = "MarineQuest",
            QuestLevel = 1,
            MobName = "Trainee [Lv. 5]",
            Mon = "Trainee",
            NPCPosition = CFrame.new(-2709.67944, 24.5206585, 2104.24585),
            LevelRange = {1, 9},
            MobSpawns = _mobSpawnCache["Trainee"] or {}
        }
    else
        return {
            QuestName = "BanditQuest1",
            QuestLevel = 1,
            MobName = "Bandit [Lv. 5]",
            Mon = "Bandit",
            NPCPosition = CFrame.new(1059.99731, 16.9222069, 1549.28162),
            LevelRange = {1, 9},
            MobSpawns = _mobSpawnCache["Bandit"] or {}
        }
    end
end

--[[
    PRIVATE: Get Fishman quest (special handling)
    @param level number
    @return table
]]
function QuestSystem:_getFishmanQuest(level)
    local mobName, mon
    
    if level >= 375 and level <= 399 then
        mobName = "Fishman Warrior [Lv. 375]"
        mon = "Fishman Warrior"
    else
        mobName = "Fishman Commando [Lv. 400]"
        mon = "Fishman Commando"
    end
    
    return {
        QuestName = "FishmanQuest",
        QuestLevel = 1,
        MobName = mobName,
        Mon = mon,
        NPCPosition = CFrame.new(61122.5625, 18.4716396, 1568.16504),
        LevelRange = {375, 449},
        RequiresEntry = true,
        EntryVector = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875),
        MobSpawns = _mobSpawnCache[self:_cleanMobName(mon)] or {}
    }
end

--[[
    PRIVATE: Load GuideModule
    @return table?
]]
function QuestSystem:_getGuideModule()
    local success, module = pcall(function()
        return require(game:GetService("ReplicatedStorage").GuideModule)
    end)
    
    return success and module or nil
end

--[[
    PRIVATE: Load Quests module
    @return table?
]]
function QuestSystem:_getQuestsModule()
    local success, module = pcall(function()
        return require(game:GetService("ReplicatedStorage").Quests)
    end)
    
    return success and module or nil
end

--[[
    PRIVATE: Find quest in game modules
    @param level number
    @param guideModule table
    @param questsModule table
    @return table?
]]
function QuestSystem:_findQuestInModules(level, guideModule, questsModule)
    local npcPosition, questLevel, levelRequire
    
    -- Search GuideModule
    if guideModule and guideModule.Data and guideModule.Data.NPCList then
        for npc, data in pairs(guideModule.Data.NPCList) do
            for qLevel, reqLevel in pairs(data.Levels) do
                if level >= reqLevel then
                    if not levelRequire or reqLevel > levelRequire then
                        npcPosition = npc.CFrame
                        questLevel = qLevel
                        levelRequire = reqLevel
                    end
                end
            end
        end
    end
    
    -- Find quest details in Quests module
    local questName, mobName, mon
    
    if questsModule and levelRequire then
        for qName, qData in pairs(questsModule) do
            for qLevel, qInfo in pairs(qData) do
                if qInfo.LevelReq == levelRequire and qName ~= "CitizenQuest" then
                    questName = qName
                    
                    for mobFullName, _ in pairs(qInfo.Task) do
                        mobName = mobFullName
                        mon = string.split(mobFullName, " [Lv. ")[1]
                    end
                end
            end
        end
    end
    
    -- Special fixes
    questName, questLevel, mobName, mon = self:_applyQuestFixes(
        questName, questLevel, mobName, mon, levelRequire
    )
    
    -- Get mob spawns
    local mobSpawns = _mobSpawnCache[self:_cleanMobName(mon or "")] or {}
    
    return {
        QuestName = questName,
        QuestLevel = questLevel,
        MobName = mobName,
        Mon = mon,
        NPCPosition = npcPosition,
        LevelRequire = levelRequire,
        MobSpawns = mobSpawns
    }
end

--[[
    PRIVATE: Apply special fixes for quests
]]
function QuestSystem:_applyQuestFixes(questName, questLevel, mobName, mon, levelRequire)
    -- Fix MarineQuest2
    if questName == "MarineQuest2" then
        questLevel = 1
        mobName = "Chief Petty Officer [Lv. 120]"
        mon = "Chief Petty Officer"
        levelRequire = 120
    end
    
    -- Fix ImpelQuest -> PrisonerQuest
    if questName == "ImpelQuest" then
        questName = "PrisonerQuest"
        questLevel = 2
        mobName = "Dangerous Prisoner [Lv. 210]"
        mon = "Dangerous Prisoner"
        levelRequire = 210
    end
    
    -- Fix Area2Quest
    if questName == "Area2Quest" and questLevel == 2 then
        questLevel = 1
        mobName = "Swan Pirate [Lv. 775]"
        mon = "Swan Pirate"
        levelRequire = 775
    end
    
    return questName, questLevel, mobName, mon
end

--[[
    PUBLIC: Start quest
    @return boolean
]]
function QuestSystem:StartQuest()
    local quest = self:GetCurrentQuest()
    if not quest then
        warn("[QUESTSYSTEM] No quest available")
        return false
    end
    
    local success, result = pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(
            "StartQuest",
            quest.QuestName,
            quest.QuestLevel
        )
    end)
    
    if success then
        print(string.format("[QUESTSYSTEM] Started: %s (Level %d)", 
            quest.QuestName, quest.QuestLevel))
    end
    
    return success
end

--[[
    PUBLIC: Abandon current quest
]]
function QuestSystem:AbandonQuest()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
    print("[QUESTSYSTEM] Quest abandoned")
end

--[[
    PUBLIC: Check if quest is active
    @return boolean
]]
function QuestSystem:IsQuestActive()
    local questGui = Services.LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
    return questGui and questGui.Visible or false
end

--[[
    PUBLIC: Verify quest matches current mob
    @param mobName string
    @return boolean
]]
function QuestSystem:VerifyQuest(mobName)
    if not self:IsQuestActive() then return false end
    
    local quest = self:GetCurrentQuest()
    if not quest then return false end
    
    local questGui = Services.LocalPlayer.PlayerGui.Main.Quest
    local titleText = questGui.Container.QuestTitle.Title.Text
    
    return string.find(titleText, quest.Mon) ~= nil
end

--[[
    PUBLIC: Get mob spawn locations
    @param mobName string?
    @return table - Array of CFrames
]]
function QuestSystem:GetMobSpawns(mobName)
    if not mobName then
        local quest = self:GetCurrentQuest()
        mobName = quest and quest.Mon
    end
    
    if not mobName then return {} end
    
    local cleanName = self:_cleanMobName(mobName)
    return _mobSpawnCache[cleanName] or {}
end

return QuestSystem