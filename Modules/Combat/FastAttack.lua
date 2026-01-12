--[[
    ================================================================
         AETHER HUB - FastAttack Module (v3.0)
    ================================================================
    
    ADVANCED COMBAT FRAMEWORK INTEGRATION:
    ✓ CombatFramework manipulation
    ✓ Multi-hit detection
    ✓ Attack speed modes (Fast/Normal/Slow)
    ✓ Hitbox expansion
    ✓ Animation bypass
    
    BASED ON: Silver Hub Professional Techniques
    DEPENDENCIES: Services, Variables
]]

--// MODULE
local FastAttack = {}
FastAttack.__index = FastAttack

--// DEPENDENCIES
local Services = nil
local Variables = nil

--// COMBAT FRAMEWORK REFERENCES
local CombatFramework = nil
local CombatFrameworkR = nil
local RigController = nil
local RigControllerR = nil
local RealBHit = nil

--// PRIVATE STATE
local _enabled = false
local _attackMode = "Fast" -- Fast, Normal, Slow
local _lastAttackTime = 0
local _hitboxSize = 60
local _connections = {}

--// CONSTANTS
local ATTACK_COOLDOWNS = {
    Fast = 0.01,
    Normal = 0.1,
    Slow = 0.7
}

local HITBOX_SIZE = 60

--[[
    Constructor
    @param services table
    @param variables table
]]
function FastAttack.new(services, variables)
    local self = setmetatable({}, FastAttack)
    
    Services = services or error("[FASTATTACK] Services required")
    Variables = variables or error("[FASTATTACK] Variables required")
    
    -- Initialize Combat Framework
    self:_initializeCombatFramework()
    
    -- Start attack loop
    self:_startAttackLoop()
    
    return self
end

--[[
    PRIVATE: Initialize Combat Framework references
]]
function FastAttack:_initializeCombatFramework()
    local success, error = pcall(function()
        -- Get CombatFramework module
        local playerScripts = Services.LocalPlayer.PlayerScripts
        local combatModule = playerScripts:WaitForChild("CombatFramework")
        
        CombatFramework = require(combatModule)
        CombatFrameworkR = debug.getupvalues(CombatFramework)[2]
        
        -- Get RigController
        local rigModule = combatModule.RigController
        RigController = require(rigModule)
        RigControllerR = debug.getupvalues(RigController)[2]
        
        -- Get RigLib
        RealBHit = require(game.ReplicatedStorage.CombatFramework.RigLib)
        
        print("[FASTATTACK] Combat Framework initialized successfully")
    end)
    
    if not success then
        warn("[FASTATTACK] Failed to initialize Combat Framework:", error)
    end
end

--[[
    PRIVATE: Get all blade hits in range
    @param size number
    @return table - Array of HumanoidRootParts
]]
function FastAttack:_getAllBladeHits(size)
    local hits = {}
    local client = Services.LocalPlayer
    local enemies = Services.Workspace.Enemies:GetChildren()
    
    for _, enemy in ipairs(enemies) do
        local humanoid = enemy:FindFirstChildOfClass("Humanoid")
        
        if humanoid and humanoid.RootPart and humanoid.Health > 0 then
            local distance = client:DistanceFromCharacter(humanoid.RootPart.Position)
            
            if distance < size + 5 then
                table.insert(hits, humanoid.RootPart)
            end
        end
    end
    
    return hits
end

--[[
    PRIVATE: Get current weapon name
    @return string
]]
function FastAttack:_getCurrentWeapon()
    if not CombatFrameworkR then return nil end
    
    local activeController = CombatFrameworkR.activeController
    if not activeController then return nil end
    
    local blade = activeController.blades[1]
    if not blade then
        local tool = Services.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        return tool and tool.Name or nil
    end
    
    pcall(function()
        while blade.Parent ~= Services.LocalPlayer.Character do
            blade = blade.Parent
        end
    end)
    
    if not blade then
        local tool = Services.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        return tool and tool.Name or nil
    end
    
    return blade.Name or blade
end

--[[
    PRIVATE: Execute fast attack
]]
function FastAttack:_executeAttack()
    if not CombatFrameworkR then return false end
    
    local activeController = CombatFrameworkR.activeController
    if not activeController or not activeController.equipped then
        return false
    end
    
    -- Get blade hits
    local bladeHits = self:_getAllBladeHits(_hitboxSize)
    if #bladeHits == 0 then return false end
    
    -- Attack logic (Silver Hub method)
    local attack5 = debug.getupvalue(activeController.attack, 5)
    local attack6 = debug.getupvalue(activeController.attack, 6)
    local attack4 = debug.getupvalue(activeController.attack, 4)
    local attack7 = debug.getupvalue(activeController.attack, 7)
    
    local number12 = (attack5 * 798405 + attack4 * 727595) % attack6
    local number13 = attack4 * 798405
    
    number12 = (number12 * attack6 + number13) % 1099511627776
    attack5 = math.floor(number12 / attack6)
    attack4 = number12 - attack5 * attack6
    
    attack7 = attack7 + 1
    
    debug.setupvalue(activeController.attack, 5, attack5)
    debug.setupvalue(activeController.attack, 6, attack6)
    debug.setupvalue(activeController.attack, 4, attack4)
    debug.setupvalue(activeController.attack, 7, attack7)
    
    -- Play animations
    if activeController.animator and activeController.animator.anims.basic then
        for _, anim in pairs(activeController.animator.anims.basic) do
            anim:Play(0.01, 0.01, 0.01)
        end
    end
    
    -- Fire remote events
    local character = Services.LocalPlayer.Character
    local tool = character:FindFirstChildOfClass("Tool")
    
    if tool and activeController.blades and activeController.blades[1] then
        local weaponName = self:_getCurrentWeapon()
        
        game:GetService("ReplicatedStorage").RigControllerEvent:FireServer(
            "weaponChange",
            tostring(weaponName)
        )
        
        game.ReplicatedStorage.Remotes.Validator:FireServer(
            math.floor(number12 / 1099511627776 * 16777215),
            attack7
        )
        
        game:GetService("ReplicatedStorage").RigControllerEvent:FireServer(
            "hit",
            bladeHits,
            2,
            ""
        )
    end
    
    return true
end

--[[
    PRIVATE: Normal attack (fallback)
]]
function FastAttack:_executeNormalAttack()
    if not CombatFrameworkR then return false end
    
    local activeController = CombatFrameworkR.activeController
    if not activeController or not activeController.equipped then
        return false
    end
    
    -- Expand hitbox
    if activeController.hitboxMagnitude ~= 55 then
        activeController.hitboxMagnitude = 55
    end
    
    activeController:attack()
    return true
end

--[[
    PRIVATE: Attack loop
]]
function FastAttack:_startAttackLoop()
    task.spawn(function()
        while true do
            task.wait(0.1)
            
            if not _enabled or not Variables:Get("FastAttack") then
                continue
            end
            
            local currentTime = tick()
            local cooldown = ATTACK_COOLDOWNS[_attackMode] or ATTACK_COOLDOWNS.Fast
            
            if currentTime - _lastAttackTime < cooldown then
                continue
            end
            
            -- Execute attack
            local success = self:_executeAttack()
            
            if success then
                _lastAttackTime = currentTime
            end
        end
    end)
end

--[[
    PUBLIC: Enable fast attack
]]
function FastAttack:Enable()
    _enabled = true
    Variables:Set("FastAttack", true)
    print("[FASTATTACK] Enabled - Mode:", _attackMode)
end

--[[
    PUBLIC: Disable fast attack
]]
function FastAttack:Disable()
    _enabled = false
    Variables:Set("FastAttack", false)
    print("[FASTATTACK] Disabled")
end

--[[
    PUBLIC: Toggle fast attack
]]
function FastAttack:Toggle()
    if _enabled then
        self:Disable()
    else
        self:Enable()
    end
    return _enabled
end

--[[
    PUBLIC: Set attack mode
    @param mode string - "Fast", "Normal", or "Slow"
]]
function FastAttack:SetMode(mode)
    if ATTACK_COOLDOWNS[mode] then
        _attackMode = mode
        Variables:Set("FastAttackMode", mode)
        print("[FASTATTACK] Mode changed to:", mode)
        return true
    end
    return false
end

--[[
    PUBLIC: Get current mode
    @return string
]]
function FastAttack:GetMode()
    return _attackMode
end

--[[
    PUBLIC: Set hitbox size
    @param size number
]]
function FastAttack:SetHitboxSize(size)
    if size >= 10 and size <= 100 then
        _hitboxSize = size
        print("[FASTATTACK] Hitbox size:", size)
        return true
    end
    return false
end

--[[
    PUBLIC: Is enabled
    @return boolean
]]
function FastAttack:IsEnabled()
    return _enabled
end

--[[
    PUBLIC: Get stats
    @return table
]]
function FastAttack:GetStats()
    return {
        Enabled = _enabled,
        Mode = _attackMode,
        HitboxSize = _hitboxSize,
        LastAttackTime = _lastAttackTime,
        Cooldown = ATTACK_COOLDOWNS[_attackMode]
    }
end

--[[
    PUBLIC: Destroy
]]
function FastAttack:Destroy()
    self:Disable()
    
    for _, connection in pairs(_connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    _connections = {}
end

return FastAttack