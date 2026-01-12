--[[
    ================================================================
         AETHER HUB - AutoQuest Module (v3.0)
    ================================================================
    
    FEATURES:
    ✓ Auto accept best quest for level
    ✓ Quest tracking
    ✓ Quest completion detection
    ✓ Auto NPC interaction
    
    DEPENDENCIES: Services, Variables, Teleporter
]]

--// MODULE
local AutoQuest = {}
AutoQuest.__index = AutoQuest

--// DEPENDENCIES
local Services = nil
local Variables = nil
local Teleporter = nil

--// PRIVATE STATE
local _running = false
local _currentQuest = nil
local _connections = {}

--// QUEST STATES
local States = {
    IDLE = "Idle",
    GETTING_QUEST = "Getting Quest",
    FARMING = "Farming",
    COMPLETING = "Completing"
}

local _currentState = States.IDLE

local QUEST_DATABASE = {
    --// SEA 1 (First Sea)
    ["Sea1"] = {
        {MinLevel = 1,    MaxLevel = 10,   NPC = "Bandit Quest",           Name = "BanditQuest1",    Target = "Bandits",            Position = CFrame.new(-1568, 14, 1530)},
        {MinLevel = 10,   MaxLevel = 15,   NPC = "Monkey Quest",           Name = "JungleQuest",     Target = "Monkeys",            Position = CFrame.new(-1579, 38, 155)},
        {MinLevel = 15,   MaxLevel = 30,   NPC = "Gorilla Quest",          Name = "JungleQuest",     Target = "Gorillas",           Position = CFrame.new(-1187, 4, 3836)},
        {MinLevel = 30,   MaxLevel = 60,   NPC = "Pirate Quest",           Name = "BuggyQuest1",     Target = "Pirates",            Position = CFrame.new(-1131, 4, 3997)},
        {MinLevel = 60,   MaxLevel = 90,   NPC = "Desert Bandit Quest",    Name = "DesertQuest",     Target = "Desert Bandits",     Position = CFrame.new(947, 6, 4418)},
        {MinLevel = 90,   MaxLevel = 120,  NPC = "Snow Bandit Quest",      Name = "SnowQuest",       Target = "Snow Bandits",       Position = CFrame.new(1384, 87, -1303)},
        {MinLevel = 120,  MaxLevel = 150,  NPC = "Chief Petty Officer",    Name = "MarineQuest1",    Target = "Trainees",           Position = CFrame.new(-4812, 49, 4316)},
        {MinLevel = 150,  MaxLevel = 190,  NPC = "Sky Bandit Quest",       Name = "SkyQuest",        Target = "Sky Bandits",        Position = CFrame.new(-4902, 834, -2622)},
        {MinLevel = 190,  MaxLevel = 250,  NPC = "Prisoner Quest",         Name = "PrisonerQuest",   Target = "Prisoners",          Position = CFrame.new(5292, 1, 475)},
        {MinLevel = 250,  MaxLevel = 350,  NPC = "Magma Ninja Quest",      Name = "MagmaQuest",      Target = "Military Soldiers",  Position = CFrame.new(-5307, 12, 8515)},
        {MinLevel = 350,  MaxLevel = 450,  NPC = "Fishman Quest",          Name = "FishmanQuest",    Target = "Fishmen",            Position = CFrame.new(6112, 18, 1567)},
    },

    --// SEA 2 (Second Sea)
    ["Sea2"] = {
        {MinLevel = 700,  MaxLevel = 775,  NPC = "Raider Quest",           Name = "Area1Quest",      Target = "Raiders",            Position = CFrame.new(-424, 73, 1782)},
        {MinLevel = 775,  MaxLevel = 875,  NPC = "Mercenary Quest",        Name = "Area2Quest",      Target = "Mercenaries",        Position = CFrame.new(584, 73, 1137)},
        {MinLevel = 875,  MaxLevel = 950,  NPC = "Swan Pirate Quest",      Name = "Area3Quest",      Target = "Swan Pirates",       Position = CFrame.new(2296, 11, 855)},
        {MinLevel = 950,  MaxLevel = 1000, NPC = "Marine Captain Quest",   Name = "MarineQuest2",    Target = "Marine Captains",    Position = CFrame.new(-4863, 18, -1932)},
        {MinLevel = 1000, MaxLevel = 1100, NPC = "Zombie Quest",           Name = "ZombieQuest",     Target = "Zombies",            Position = CFrame.new(-5538, 48, -803)},
        {MinLevel = 1100, MaxLevel = 1250, NPC = "Vampire Quest",          Name = "VampireQuest",    Target = "Vampires",           Position = CFrame.new(-6201, 15, -4835)},
        {MinLevel = 1250, MaxLevel = 1350, NPC = "Snow Lurker Quest",      Name = "SnowMountainQuest", Target = "Snow Lurkers",     Position = CFrame.new(510, 401, -4918)},
        {MinLevel = 1350, MaxLevel = 1425, NPC = "Ice Castle Quest",       Name = "IceCastleQuest",  Target = "Arctic Warriors",    Position = CFrame.new(-6066, 15, -5010)},
        {MinLevel = 1425, MaxLevel = 1500, NPC = "Forgotten Quest",        Name = "ForgottenQuest",  Target = "Sea Soldiers",       Position = CFrame.new(-3040, 217, -10156)},
    },

    --// SEA 3 (Third Sea) - Máximo Nivel
    ["Sea3"] = {
        {MinLevel = 1500, MaxLevel = 1575, NPC = "Pirate Millionaire",     Name = "PortTownQuest",   Target = "Pirate Millionaires", Position = CFrame.new(-434, 73, 5588)},
        {MinLevel = 1575, MaxLevel = 1650, NPC = "Pistol Marine Quest",    Name = "MarineQuest3",    Target = "Pistol Marines",     Position = CFrame.new(-470, 75, 5320)},
        {MinLevel = 1650, MaxLevel = 1725, NPC = "Island Empress Quest",   Name = "HydraQuest",      Target = "Dragon Crew Warriors",Position = CFrame.new(5228, 465, 356)},
        {MinLevel = 1725, MaxLevel = 1825, NPC = "Great Tree Quest",       Name = "GreatTreeQuest",  Target = "Marine Officers",    Position = CFrame.new(2179, 28, -6739)},
        {MinLevel = 1825, MaxLevel = 1975, NPC = "Floating Turtle Quest",  Name = "TurtleQuest",     Target = "Fishman Raiders",    Position = CFrame.new(-13232, 531, -7698)},
        {MinLevel = 1975, MaxLevel = 2075, NPC = "Haunted Castle Quest",   Name = "HauntedQuest",    Target = "Reborn Skeletons",   Position = CFrame.new(-9508, 170, 5765)},
        {MinLevel = 2075, MaxLevel = 2200, NPC = "Ice Cream Quest",        Name = "CandyQuest",      Target = "Cookie Pirates",     Position = CFrame.new(-2180, 28, -10242)},
        {MinLevel = 2200, MaxLevel = 2450, NPC = "Cake Island Quest",      Name = "CakeQuest",       Target = "Cake Guards",        Position = CFrame.new(-2020, 38, -12025)},
        {MinLevel = 2450, MaxLevel = 2550, NPC = "Tiki Outpost Quest",     Name = "TikiQuest",       Target = "Sun-kissed Warriors",Position = CFrame.new(-11760, 331, -8826)},
    }
}

--[[
    Constructor
    @param services table
    @param variables table
    @param teleporter table
]]
function AutoQuest.new(services, variables, teleporter)
    local self = setmetatable({}, AutoQuest)
    
    Services = services or error("[AUTOQUEST] Services required")
    Variables = variables or error("[AUTOQUEST] Variables required")
    Teleporter = teleporter or error("[AUTOQUEST] Teleporter required")
    
    return self
end

--[[
    PRIVATE: Get current sea
    @return string?
]]
function AutoQuest:_getCurrentSea()
    local placeId = game.PlaceId
    
    if placeId == 2753915549 then return "Sea1"
    elseif placeId == 4442272183 then return "Sea2"
    elseif placeId == 7449423635 then return "Sea3"
    end
    
    return nil
end

--[[
    PRIVATE: Get player level
    @return number
]]
function AutoQuest:_getLevel()
    if not Services or not Services.LocalPlayer then return 0 end
    
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if not data then return 0 end
    
    local level = data:FindFirstChild("Level")
    if not level then return 0 end
    
    return level.Value or 0
end

--[[
    PRIVATE: Get best quest for level
    @return table?
]]
function AutoQuest:_getBestQuest()
    local sea = self:_getCurrentSea()
    if not sea then return nil end
    
    local quests = QUESTS[sea]
    if not quests then return nil end
    
    local level = self:_getLevel()
    
    for _, quest in ipairs(quests) do
        if level >= quest.MinLevel and level <= quest.MaxLevel then
            return quest
        end
    end
    
    -- Return last quest if overleveled
    return quests[#quests]
end

--[[
    PRIVATE: Check if has quest
    @return boolean
]]
function AutoQuest:_hasQuest()
    local data = Services.LocalPlayer:FindFirstChild("Data")
    if not data then return false end
    
    local quest = data:FindFirstChild("Quest")
    return quest and quest.Value ~= ""
end

--[[
    PRIVATE: Get quest from NPC
    @param questName string
    @param location CFrame
]]
function AutoQuest:_getQuest(questName, location)
    -- Teleport to quest NPC
    Teleporter:TeleportTo(location, {useTween = false})
    task.wait(0.5)
    
    -- Find and interact with quest NPC
    local quests = Services.Workspace:FindFirstChild("Quests")
    if quests then
        for _, npc in ipairs(quests:GetChildren()) do
            if npc.Name:find(questName:gsub(" Quest", "")) then
                -- Try to get quest via remote
                local commF = Services:GetCommF()
                if commF then
                    pcall(function()
                        commF:InvokeServer("StartQuest", npc.Name, 1)
                    end)
                end
                break
            end
        end
    end
end

--[[
    PRIVATE: Main quest loop
]]
function AutoQuest:_questLoop()
    while _running do
        if not Variables:Get("AutoQuest") then
            task.wait(1)
            continue
        end
        
        if _currentState == States.IDLE then
            _currentState = States.GETTING_QUEST
            
        elseif _currentState == States.GETTING_QUEST then
            if not self:_hasQuest() then
                local quest = self:_getBestQuest()
                if quest then
                    _currentQuest = quest
                    self:_getQuest(quest.QuestNPC, quest.Location)
                    task.wait(1)
                end
            else
                _currentState = States.FARMING
            end
            
        elseif _currentState == States.FARMING then
            -- This state is handled by AutoFarm
            -- Just check if quest is complete
            if not self:_hasQuest() then
                _currentState = States.GETTING_QUEST
            end
            task.wait(2)
            
        elseif _currentState == States.COMPLETING then
            _currentState = States.GETTING_QUEST
        end
        
        task.wait(0.5)
    end
    
    _currentState = States.IDLE
end

--[[
    PUBLIC: Start AutoQuest
]]
function AutoQuest:Start()
    if _running then return end
    
    _running = true
    Variables:Set("AutoQuest", true)
    
    task.spawn(function()
        self:_questLoop()
    end)
    
    print("[AUTOQUEST] Started")
end

--[[
    PUBLIC: Stop AutoQuest
]]
function AutoQuest:Stop()
    _running = false
    Variables:Set("AutoQuest", false)
    _currentQuest = nil
    _currentState = States.IDLE
    
    print("[AUTOQUEST] Stopped")
end

--[[
    PUBLIC: Toggle
    @return boolean
]]
function AutoQuest:Toggle()
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
function AutoQuest:IsRunning()
    return _running
end

--[[
    PUBLIC: Get current state
    @return string
]]
function AutoQuest:GetState()
    return _currentState
end

--[[
    PUBLIC: Get current quest
    @return table?
]]
function AutoQuest:GetCurrentQuest()
    return _currentQuest
end

--[[
    PUBLIC: Destroy
]]
function AutoQuest:Destroy()
    self:Stop()
    
    for _, connection in pairs(_connections) do
        if connection then
            connection:Disconnect()
        end
    end
    _connections = {}
end

return AutoQuest
