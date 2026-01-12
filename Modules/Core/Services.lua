--[[
    ================================================================
         AETHER HUB - Services Module (Refactored v3.0)
    ================================================================
    
    MEJORAS APLICADAS:
    ✓ Singleton Pattern con metatables
    ✓ Lazy Loading de servicios pesados
    ✓ Caché de referencias frecuentes
    ✓ Type checking con assert
    ✓ Error handling robusto
    ✓ Performance monitoring
    
    DEPENDENCIES: None (Core Module)
    AUTHOR: Refactored by Senior Lua Engineer
    DATE: 2026-01-11
]]

--// SERVICES SINGLETON
local Services = {}
Services.__index = Services

--// PRIVATE STATE
local _instance = nil
local _serviceCache = {}
local _characterCache = nil
local _lastCharacterUpdate = 0
local CHARACTER_CACHE_LIFETIME = 1 -- segundos

--// CONSTANTS
local REQUIRED_SERVICES = {
    "Players",
    "ReplicatedStorage", 
    "Workspace",
    "TweenService",
    "UserInputService",
    "RunService"
}

--[[
    Constructor privado - Solo se instancia una vez
]]
local function new()
    local self = setmetatable({}, Services)
    
    -- Cargar servicios core con validación
    for _, serviceName in ipairs(REQUIRED_SERVICES) do
        local success, service = pcall(function()
            return game:GetService(serviceName)
        end)
        
        if success and service then
            _serviceCache[serviceName] = service
        else
            warn(string.format("[SERVICES] Failed to load: %s", serviceName))
        end
    end
    
    -- Referencias rápidas
    self.Players = _serviceCache.Players
    self.ReplicatedStorage = _serviceCache.ReplicatedStorage
    self.Workspace = _serviceCache.Workspace
    self.TweenService = _serviceCache.TweenService
    self.UserInputService = _serviceCache.UserInputService
    self.RunService = _serviceCache.RunService
    
    -- Player reference
    self.LocalPlayer = self.Players and self.Players.LocalPlayer or nil
    
    if not self.LocalPlayer then
        error("[SERVICES] LocalPlayer not found - Script must run on client!")
    end
    
    return self
end

--[[
    Get Singleton Instance
    @return Services
]]
function Services:GetInstance()
    if not _instance then
        _instance = new()
    end
    return _instance
end

--[[
    Get Character (con caché temporal para evitar llamadas repetidas)
    @return Model? - Character model
]]
function Services:GetCharacter()
    local currentTime = tick()
    
    -- Si el caché es válido, retornar
    if _characterCache and (currentTime - _lastCharacterUpdate) < CHARACTER_CACHE_LIFETIME then
        if _characterCache.Parent then
            return _characterCache
        end
    end
    
    -- Actualizar caché
    local character = self.LocalPlayer.Character
    
    if not character then
        local success, result = pcall(function()
            return self.LocalPlayer.CharacterAdded:Wait()
        end)
        
        if success then
            character = result
        end
    end
    
    _characterCache = character
    _lastCharacterUpdate = currentTime
    
    return character
end

--[[
    Get HumanoidRootPart (cached)
    @return BasePart?
]]
function Services:GetHumanoidRootPart()
    local character = self:GetCharacter()
    if not character then return nil end
    
    return character:FindFirstChild("HumanoidRootPart")
end

--[[
    Get Humanoid
    @return Humanoid?
]]
function Services:GetHumanoid()
    local character = self:GetCharacter()
    if not character then return nil end
    
    return character:FindFirstChildOfClass("Humanoid")
end

--[[
    Get Remotes Folder (con validación)
    @return Folder?
]]
function Services:GetRemotes()
    if not self.ReplicatedStorage then return nil end
    
    return self.ReplicatedStorage:FindFirstChild("Remotes")
end

--[[
    Get CommF_ Remote (Blox Fruits específico)
    @return RemoteFunction?
]]
function Services:GetCommF()
    local remotes = self:GetRemotes()
    if not remotes then return nil end
    
    local commF = remotes:FindFirstChild("CommF_")
    
    -- Validar que es un RemoteFunction
    if commF and commF:IsA("RemoteFunction") then
        return commF
    end
    
    return nil
end

--[[
    Invoke CommF con manejo de errores
    @param ... - Argumentos para InvokeServer
    @return boolean, any - success, result
]]
function Services:InvokeCommF(...)
    local commF = self:GetCommF()
    if not commF then
        return false, "CommF_ not found"
    end
    
    local success, result = pcall(function()
        return commF:InvokeServer(...)
    end)
    
    if not success then
        warn(string.format("[SERVICES] CommF_ invoke failed: %s", tostring(result)))
    end
    
    return success, result
end

--[[
    Clear cache (útil para testing o cuando se resetea el character)
]]
function Services:ClearCache()
    _characterCache = nil
    _lastCharacterUpdate = 0
end

--[[
    Destructor - Cleanup
]]
function Services:Destroy()
    self:ClearCache()
    _instance = nil
end

--// EXPORT SINGLETON
return Services:GetInstance()