--[[
    ================================================================
         AETHER HUB - AutoFarm Level (v3.0 Complete)
    ================================================================
    
    COMPLETE AUTO FARM SYSTEM:
    ✓ Quest system integration
    ✓ Fast attack integration
    ✓ Bring mob integration
    ✓ Advanced teleportation
    ✓ Bypass system for long distances
    ✓ Multi-spawn support
    ✓ Equipment management
    
    BASED ON: Silver Hub Professional System
    DEPENDENCIES: Services, Variables, Teleporter, QuestSystem, FastAttack, BringMob
]]

--// MODULE
local AutoFarmLevel = {}
AutoFarmLevel.__index = AutoFarmLevel

--// DEPENDENCIES
local Services = nil
local Variables = nil
local Teleporter = nil
local QuestSystem = nil
local FastAttack = nil
local BringMob = nil

--// PRIVATE STATE
local _running = false
local _currentMobSpawnIndex = 1
local _connections = {}

--// CONSTANTS
local FARM_DISTANCE = 30
local QUEST_CHECK_DISTANCE = 20
local BYPASS_DISTANCE = 3000

--[[
    Constructor
    @param services table
    @param variables table
    @param teleporter table
    @param questSystem table
    @param fastAttack table
    @param bringMob table
]]
function AutoFarmLevel.new(services, variables, teleporter, questSystem, fastAttack, bringMob)
    local self = setmetatable({}, AutoFarmLevel)
    
    Services = services or error("[AUTOFARM] Services required")
    Variables = variables or error("[AUTOFARM] Variables required")
    Teleporter = teleporter or error("[AUTOFARM] Teleporter required")
    QuestSystem = questSystem or error("[AUTOFARM] QuestSystem required")
    FastAttack = fastAttack or error("[AUTOFARM] FastAttack required")
    BringMob = bringMob or error("[AUTOFARM] BringMob required")
    
    return self
end

--[[
    PRIVATE: Check if need to bypass teleport
    @param targetPos Vector3
    @return boolean
]]
function AutoFarmLevel:_shouldBypass(targetPos)
    local hrp = Services:GetHumanoidRootPart()
    if not hrp then return false end
    
    local distance = (hrp.Position - targetPos).Magnitude
    return distance > BYPASS_DISTANCE and Variables:Get("BypassTP")
end

--[[
    PRIVATE: Bypass teleport to distant location
    @param targetCFrame CFrame
]]
function AutoFarmLevel:_bypassTeleport(targetCFrame)
    print("[AUTOFARM] Executing bypass teleport...")
    
    -- Stop current tween
    Teleporter:ClearQueue()
    
    -- Abandon quest
    QuestSystem:AbandonQuest()
    
    -- Character manipulation for bypass
    local character = Services:GetCharacter()
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Destroy head to prevent fall damage
    local head = character:FindFirstChild("Head")
    if head then
        head:Destroy()
    end
    
    -- Teleport sequence
    hrp.CFrame = targetCFrame * CFrame.new(0, 50, 0)
    task.wait(0.2)
    
    hrp.CFrame = targetCFrame
    task.wait(0.1)
    
    hrp.CFrame = targetCFrame * CFrame.new(0, 50, 0)
    hrp.Anchored = true
    task.wait(0.1)
    
    hrp.CFrame = targetCFrame
    task.wait(0.5)
    
    hrp.Anchored = false
    
    print("[AUTOFARM] Bypass complete")
    return true
end

--[[
    PRIVATE: Equip weapon
    @param weaponName string
]]
function AutoFarmLevel:_equipWeapon(weaponName)
    if not weaponName or weaponName == "" then return end
    
    local backpack = Services.LocalPlayer.Backpack
    local tool = backpack:FindFirstChild(weaponName)
    
    if tool then
        local humanoid = Services:GetHumanoid()
        if humanoid then
            humanoid:EquipTool(tool)
        end
    end
end

--[[
    PRIVATE: Unequip weapon
    @param weaponName string
]]
function AutoFarmLevel:_unequipWeapon(weaponName)
    if not weaponName or weaponName == "" then return end
    
    local character = Services:GetCharacter()
    if not character then return end
    
    local tool = character:FindFirstChild(weaponName)
    if tool then
        tool.Parent = Services.LocalPlayer.Backpack
    end
end

--[[
    PRIVATE: Main farm loop
]]
function AutoFarmLevel:_farmLoop()
    while _running do
        task.wait(0.1)
        
        if not Variables:Get("AutoFarmLevel") then
            continue
        end
        
        -- Get current quest
        local quest = QuestSystem:GetCurrentQuest()
        if not quest then
            warn("[AUTOFARM] No quest available for current level")
            task.wait(5)
            continue
        end
        
        -- Check if quest is active
        local questActive = QuestSystem:IsQuestActive()
        
        if questActive then
            -- Farm mobs
            self:_farmQuest(quest)
        else
            -- Start quest
            self:_startQuest(quest)
        end
    end
end

--[[
    PRIVATE: Start quest
    @param quest table
]]
function AutoFarmLevel:_startQuest(quest)
    local hrp = Services:GetHumanoidRootPart()
    if not hrp then return end
    
    -- Check if need to bypass
    if self:_shouldBypass(quest.NPCPosition.Position) then
        self:_bypassTeleport(quest.NPCPosition)
        return
    end
    
    -- Teleport to NPC
    local distance = (hrp.Position - quest.NPCPosition.Position).Magnitude
    
    if distance > QUEST_CHECK_DISTANCE then
        Teleporter:TeleportTo(quest.NPCPosition, {useTween = true})
        return
    end
    
    -- Start quest
    task.wait(0.2)
    QuestSystem:StartQuest()
    task.wait(0.5)
    
    -- Teleport to first mob spawn
    if quest.MobSpawns and #quest.MobSpawns > 0 then
        Teleporter:TeleportTo(quest.MobSpawns[1] * CFrame.new(0, 30, 20))
    end
end

--[[
    PRIVATE: Farm quest mobs
    @param quest table
]]
function AutoFarmLevel:_farmQuest(quest)
    -- Verify quest
    if not QuestSystem:VerifyQuest(quest.MobName) then
        QuestSystem:AbandonQuest()
        return
    end
    
    -- Check for active mobs
    local targetMob = self:_findQuestMob(quest)
    
    if targetMob then
        self:_farmMob(targetMob, quest)
    else
        self:_goToMobSpawn(quest)
    end
end

--[[
    PRIVATE: Find quest mob
    @param quest table
    @return Model?
]]
function AutoFarmLevel:_findQuestMob(quest)
    for _, enemy in ipairs(Services.Workspace.Enemies:GetChildren()) do
        if enemy.Name == quest.MobName then
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp and humanoid.Health > 0 then
                return enemy
            end
        end
    end
    
    return nil
end

--[[
    PRIVATE: Farm individual mob
    @param mob Model
    @param quest table
]]
function AutoFarmLevel:_farmMob(mob, quest)
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    local humanoid = mob:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not humanoid then return end
    
    -- Enable bring mob
    BringMob:Enable(hrp.CFrame)
    
    -- Equip weapon
    local weapon = Variables:Get("SelectWeapon")
    self:_equipWeapon(weapon)
    
    -- Enable fast attack
    FastAttack:Enable()
    
    -- Farm loop
    while _running and mob.Parent and humanoid.Health > 0 do
        task.wait(0.1)
        
        -- Verify quest still active
        if not QuestSystem:IsQuestActive() then
            break
        end
        
        -- Update bring position
        BringMob:UpdatePosition(hrp.CFrame)
        
        -- Modify mob properties
        hrp.Size = Vector3.new(60, 60, 60)
        hrp.Transparency = 1
        hrp.CanCollide = false
        humanoid.WalkSpeed = 0
        
        local head = mob:FindFirstChild("Head")
        if head then
            head.CanCollide = false
        end
        
        -- Teleport near mob
        Teleporter:TeleportTo(hrp.CFrame * CFrame.new(0, FARM_DISTANCE, 5), {useTween = false})
    end
    
    -- Cleanup
    BringMob:Disable()
    FastAttack:Disable()
end

--[[
    PRIVATE: Go to mob spawn location
    @param quest table
]]
function AutoFarmLevel:_goToMobSpawn(quest)
    if not quest.MobSpawns or #quest.MobSpawns == 0 then
        warn("[AUTOFARM] No mob spawns available")
        return
    end
    
    -- Unequip weapon while traveling
    local weapon = Variables:Get("SelectWeapon")
    self:_unequipWeapon(weapon)
    
    -- Get spawn location
    local spawnCFrame = quest.MobSpawns[_currentMobSpawnIndex]
    if not spawnCFrame then
        _currentMobSpawnIndex = 1
        spawnCFrame = quest.MobSpawns[1]
    end
    
    -- Teleport to spawn
    Teleporter:TeleportTo(spawnCFrame * CFrame.new(0, 30, 5), {useTween = true})
    
    -- Check if reached
    local hrp = Services:GetHumanoidRootPart()
    if hrp then
        local distance = (hrp.Position - spawnCFrame.Position).Magnitude
        
        if distance <= 50 then
            -- Cycle to next spawn
            _currentMobSpawnIndex = _currentMobSpawnIndex + 1
            
            if _currentMobSpawnIndex > #quest.MobSpawns then
                _currentMobSpawnIndex = 1
            end
            
            task.wait(0.5)
        end
    end
end

--[[
    PUBLIC: Start auto farm
]]
function AutoFarmLevel:Start()
    if _running then
        warn("[AUTOFARM] Already running")
        return
    end
    
    _running = true
    Variables:Set("AutoFarmLevel", true)
    
    -- Start farm loop
    task.spawn(function()
        self:_farmLoop()
    end)
    
    print("[AUTOFARM] Auto Farm Level started")
end

--[[
    PUBLIC: Stop auto farm
]]
function AutoFarmLevel:Stop()
    _running = false
    Variables:Set("AutoFarmLevel", false)
    
    -- Cleanup
    BringMob:Disable()
    FastAttack:Disable()
    Teleporter:ClearQueue()
    
    print("[AUTOFARM] Auto Farm Level stopped")
end

--[[
    PUBLIC: Toggle
]]
function AutoFarmLevel:Toggle()
    if _running then
        self:Stop()
    else
        self:Start()
    end
    return _running
end

--[[
    PUBLIC: Is running
    @return boolean
]]
function AutoFarmLevel:IsRunning()
    return _running
end

--[[
    PUBLIC: Get current level
    @return number
]]
function AutoFarmLevel:GetLevel()
    return Services.LocalPlayer.Data.Level.Value or 0
end

--[[
    PUBLIC: Get stats
    @return table
]]
function AutoFarmLevel:GetStats()
    local quest = QuestSystem:GetCurrentQuest()
    
    return {
        Running = _running,
        Level = self:GetLevel(),
        CurrentQuest = quest and quest.QuestName or "None",
        QuestActive = QuestSystem:IsQuestActive(),
        FastAttack = FastAttack:IsEnabled(),
        BringMob = BringMob:IsEnabled()
    }
end

--[[
    PUBLIC: Destroy
]]
function AutoFarmLevel:Destroy()
    self:Stop()
    
    for _, connection in pairs(_connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    _connections = {}
end

return AutoFarmLevel