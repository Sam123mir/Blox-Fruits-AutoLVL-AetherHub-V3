--[[
    ================================================================
         AETHER HUB - Island Teleport Module (v3.0)
    ================================================================
    
    FEATURES:
    ✓ All Sea 1, 2, 3 islands
    ✓ Important locations
    ✓ Safe teleport with height offset
    ✓ Searchable island list
    
    DEPENDENCIES: Services, Teleporter
]]

--// MODULE
local IslandTeleport = {}
IslandTeleport.__index = IslandTeleport

--// DEPENDENCIES
local Services = nil
local Teleporter = nil

--// ISLAND DATABASE
local ISLANDS = {
    --// SEA 1 (First Sea) - El Nuevo Mundo
    ["Sea1"] = {
        ["Starter Island"]     = {Position = CFrame.new(-511, 53, 1965),   Level = 0},
        ["Jungle"]             = {Position = CFrame.new(-1277, 69, 356),   Level = 15},
        ["Pirate Village"]     = {Position = CFrame.new(-1085, 45, 3827),  Level = 30},
        ["Desert"]             = {Position = CFrame.new(915, 69, 4397),    Level = 60},
        ["Middle Town"]        = {Position = CFrame.new(-656, 47, 1546),   Level = 100},
        ["Frozen Village"]     = {Position = CFrame.new(1155, 45, -1318),  Level = 90},
        ["Marine Fortress"]    = {Position = CFrame.new(-4743, 45, 4353),  Level = 120},
        ["Skylands"]           = {Position = CFrame.new(-4826, 721, -2612), Level = 150},
        ["Prison"]             = {Position = CFrame.new(4873, 6, 733),     Level = 190},
        ["Colosseum"]          = {Position = CFrame.new(-1493, 43, -2841), Level = 225},
        ["Magma Village"]      = {Position = CFrame.new(-5242, 45, 8519),  Level = 300},
        ["Underwater City"]    = {Position = CFrame.new(6116, 18, 1569),   Level = 375},
        ["Fountain City"]      = {Position = CFrame.new(5241, 67, 4088),   Level = 625},
        ["Blox Fruits Dealer"] = {Position = CFrame.new(-26, 15, 1820),    Level = 0},
    },
    
    --// SEA 2 (Second Sea)
    ["Sea2"] = {
        ["Kingdom of Rose"]    = {Position = CFrame.new(-313, 72, 1668),    Level = 700},
        ["Cafe"]               = {Position = CFrame.new(-378, 39, 251),     Level = 700},
        ["Usoapp's Island"]    = {Position = CFrame.new(4728, 46, -723),    Level = 700},
        ["Green Zone"]         = {Position = CFrame.new(-2414, 73, -3217),  Level = 875},
        ["Graveyard"]          = {Position = CFrame.new(-5428, 48, -792),   Level = 950},
        ["Snow Mountain"]      = {Position = CFrame.new(603, 400, -5295),   Level = 1000},
        ["Hot and Cold"]       = {Position = CFrame.new(-5935, 56, -869),   Level = 1100},
        ["Cursed Ship"]        = {Position = CFrame.new(923, 90, 32885),   Level = 1000},
        ["Ice Castle"]         = {Position = CFrame.new(-6041, 56, -4827),  Level = 1350},
        ["Forgotten Island"]   = {Position = CFrame.new(-3041, 217, -10156),Level = 1425},
        ["Dark Arena"]         = {Position = CFrame.new(-382, 64, 11736),   Level = 1000},
        ["Mansion"]            = {Position = CFrame.new(-4563, 874, -1795), Level = 1000},
        ["Factory"]            = {Position = CFrame.new(435, 74, -277),     Level = 0},
    },
    
    --// SEA 3 (Third Sea)
    ["Sea3"] = {
        ["Port Town"]          = {Position = CFrame.new(-289, 46, 5580),    Level = 1500},
        ["Hydra Island"]       = {Position = CFrame.new(5228, 465, 356),    Level = 1575},
        ["Great Tree"]         = {Position = CFrame.new(2179, 28, -6739),   Level = 1700},
        ["Floating Turtle"]    = {Position = CFrame.new(-13232, 531, -7698),Level = 1775},
        ["Mansion (Turtle)"]   = {Position = CFrame.new(-12471, 375, -7551),Level = 1800},
        ["Castle on the Sea"]  = {Position = CFrame.new(-5065, 315, -3037), Level = 0},
        ["Haunted Castle"]     = {Position = CFrame.new(-9508, 170, 5765),  Level = 1975},
        ["Sea of Treats"]      = {Position = CFrame.new(-2180, 28, -10242), Level = 2075},
        ["Tiki Outpost"]       = {Position = CFrame.new(-11760, 331, -8826),Level = 2450},
        ["Kitsune Shrine"]     = {Position = CFrame.new(-10488, 466, -9206),Level = 0},
    },

    --// LOCACIONES ESPECIALES
    ["Special"] = {
        ["Mirage Island"]      = {Position = CFrame.new(-14000, 300, -7000)},
        ["Safe Zone"]          = {Position = CFrame.new(0, 100, 0)},
    }
}

--[[
    Constructor
    @param services table
    @param teleporter table
]]
function IslandTeleport.new(services, teleporter)
    local self = setmetatable({}, IslandTeleport)
    
    Services = services or error("[ISLANDTELEPORT] Services required")
    Teleporter = teleporter or error("[ISLANDTELEPORT] Teleporter required")
    
    return self
end

--[[
    PUBLIC: Get current sea
    @return string
]]
function IslandTeleport:GetCurrentSea()
    local placeId = game.PlaceId
    
    if placeId == 2753915549 then
        return "Sea1"
    elseif placeId == 4442272183 then
        return "Sea2"
    elseif placeId == 7449423635 then
        return "Sea3"
    else
        return nil
    end
end

--[[
    PUBLIC: Get islands for current sea
    @return table
]]
function IslandTeleport:GetCurrentSeaIslands()
    local sea = self:GetCurrentSea()
    if not sea then return {} end
    
    return ISLANDS[sea] or {}
end

--[[
    PUBLIC: Get all islands for a sea
    @param sea string - "Sea1", "Sea2", "Sea3"
    @return table
]]
function IslandTeleport:GetIslands(sea)
    return ISLANDS[sea] or {}
end

--[[
    PUBLIC: Get island names for current sea
    @return table - Array of names
]]
function IslandTeleport:GetIslandNames()
    local islands = self:GetCurrentSeaIslands()
    local names = {}
    
    for _, island in ipairs(islands) do
        table.insert(names, island.Name)
    end
    
    return names
end

--[[
    PUBLIC: Find island by name
    @param name string
    @return table? - Island data
]]
function IslandTeleport:FindIsland(name)
    local sea = self:GetCurrentSea()
    if not sea then return nil end
    
    local islands = ISLANDS[sea]
    if not islands then return nil end
    
    for _, island in ipairs(islands) do
        if island.Name:lower() == name:lower() then
            return island
        end
    end
    
    -- Partial match
    for _, island in ipairs(islands) do
        if island.Name:lower():find(name:lower()) then
            return island
        end
    end
    
    return nil
end

--[[
    PUBLIC: Teleport to island by name
    @param name string
    @return boolean, string - success, message
]]
function IslandTeleport:TeleportTo(name)
    local island = self:FindIsland(name)
    
    if not island then
        return false, "Island not found: " .. name
    end
    
    -- Teleport with safe offset (above ground)
    local safePos = island.Position * CFrame.new(0, 5, 0)
    Teleporter:TeleportTo(safePos, {useTween = false})
    
    return true, "Teleported to " .. island.Name
end

--[[
    PUBLIC: Teleport by index
    @param index number
    @return boolean, string
]]
function IslandTeleport:TeleportByIndex(index)
    local islands = self:GetCurrentSeaIslands()
    
    if index < 1 or index > #islands then
        return false, "Invalid island index"
    end
    
    local island = islands[index]
    local safePos = island.Position * CFrame.new(0, 5, 0)
    Teleporter:TeleportTo(safePos, {useTween = false})
    
    return true, "Teleported to " .. island.Name
end

--[[
    PUBLIC: Search islands
    @param query string
    @return table - Matching islands
]]
function IslandTeleport:Search(query)
    local results = {}
    local sea = self:GetCurrentSea()
    
    if not sea then return results end
    
    local islands = ISLANDS[sea]
    if not islands then return results end
    
    query = query:lower()
    
    for _, island in ipairs(islands) do
        if island.Name:lower():find(query) then
            table.insert(results, island)
        end
    end
    
    return results
end

--[[
    PUBLIC: Get island count
    @return number
]]
function IslandTeleport:GetIslandCount()
    return #self:GetCurrentSeaIslands()
end

return IslandTeleport
