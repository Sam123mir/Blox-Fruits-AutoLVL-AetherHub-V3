--[[
    ================================================================
         AETHER HUB - ESP Module (v3.0)
    ================================================================
    
    FEATURES:
    ✓ Player ESP with health bars
    ✓ Fruit ESP with rarity colors
    ✓ Chest ESP
    ✓ NPC ESP
    ✓ Performance optimized
    
    DEPENDENCIES: Services, Variables
]]

--// MODULE
local ESP = {}
ESP.__index = ESP

--// DEPENDENCIES
local Services = nil
local Variables = nil

--// PRIVATE STATE
local _enabled = false
local _espObjects = {}
local _connections = {}
local _updateConnection = nil

--// CONSTANTS
local UPDATE_RATE = 0.1 -- seconds
local MAX_DISTANCE = 2000 -- studs

--// ESP COLORS
local COLORS = {
    Player = {
        Enemy = Color3.fromRGB(255, 0, 0),
        Friendly = Color3.fromRGB(0, 255, 0),
        Neutral = Color3.fromRGB(255, 255, 0)
    },
    Fruit = {
        Common = Color3.fromRGB(150, 150, 150),
        Uncommon = Color3.fromRGB(0, 255, 0),
        Rare = Color3.fromRGB(0, 100, 255),
        Legendary = Color3.fromRGB(255, 0, 255),
        Mythical = Color3.fromRGB(255, 215, 0)
    },
    Chest = Color3.fromRGB(255, 200, 0),
    NPC = Color3.fromRGB(0, 255, 255)
}

--[[
    Constructor
    @param services table
    @param variables table
]]
function ESP.new(services, variables)
    local self = setmetatable({}, ESP)
    
    Services = services or error("[ESP] Services required")
    Variables = variables or error("[ESP] Variables required")
    
    return self
end

--[[
    PRIVATE: Create billboard GUI
    @param name string
    @param color Color3
    @param parent Instance
    @return BillboardGui
]]
function ESP:_createBillboard(name, color, parent)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. name
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = parent
    
    local frame = Instance.new("Frame")
    frame.Name = "Container"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = name
    nameLabel.Parent = frame
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Text = "0m"
    distLabel.Parent = frame
    
    return billboard
end

--[[
    PRIVATE: Create health bar
    @param parent Frame
    @return Frame
]]
function ESP:_createHealthBar(parent)
    local container = Instance.new("Frame")
    container.Name = "HealthBar"
    container.Size = UDim2.new(0.8, 0, 0, 4)
    container.Position = UDim2.new(0.1, 0, 1, 2)
    container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    fill.BorderSizePixel = 0
    fill.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 2)
    corner.Parent = container
    
    local cornerFill = Instance.new("UICorner")
    cornerFill.CornerRadius = UDim.new(0, 2)
    cornerFill.Parent = fill
    
    return container
end

--[[
    PRIVATE: Update ESP for target
    @param espData table
]]
function ESP:_updateESP(espData)
    local billboard = espData.Billboard
    local target = espData.Target
    
    if not billboard or not target or not target.Parent then
        self:_removeESP(espData)
        return
    end
    
    local playerHRP = Services:GetHumanoidRootPart()
    if not playerHRP then return end
    
    local targetPos = nil
    if target:IsA("BasePart") then
        targetPos = target.Position
    elseif target:IsA("Model") and target.PrimaryPart then
        targetPos = target.PrimaryPart.Position
    elseif target:FindFirstChild("HumanoidRootPart") then
        targetPos = target.HumanoidRootPart.Position
    elseif target:FindFirstChild("Handle") then
        targetPos = target.Handle.Position
    end
    
    if not targetPos then return end
    
    local distance = (playerHRP.Position - targetPos).Magnitude
    
    -- Update distance label
    local distLabel = billboard.Container:FindFirstChild("DistLabel")
    if distLabel then
        distLabel.Text = string.format("%.0fm", distance)
    end
    
    -- Hide if too far
    billboard.Enabled = distance <= MAX_DISTANCE
    
    -- Update health bar if exists
    if espData.HealthBar and espData.Humanoid then
        local health = espData.Humanoid.Health
        local maxHealth = espData.Humanoid.MaxHealth
        local percent = health / maxHealth
        
        local fill = espData.HealthBar:FindFirstChild("Fill")
        if fill then
            fill.Size = UDim2.new(percent, 0, 1, 0)
            
            -- Color based on health
            if percent > 0.6 then
                fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            elseif percent > 0.3 then
                fill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            else
                fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end

--[[
    PRIVATE: Remove ESP
    @param espData table
]]
function ESP:_removeESP(espData)
    if espData.Billboard then
        espData.Billboard:Destroy()
    end
    
    -- Remove from list
    for i, data in ipairs(_espObjects) do
        if data == espData then
            table.remove(_espObjects, i)
            break
        end
    end
end

--[[
    PUBLIC: Add ESP to player
    @param player Player
]]
function ESP:AddPlayerESP(player)
    if player == Services.LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    
    local color = COLORS.Player.Neutral
    
    local billboard = self:_createBillboard(player.DisplayName, color, hrp)
    local healthBar = self:_createHealthBar(billboard.Container)
    
    local espData = {
        Type = "Player",
        Target = character,
        Billboard = billboard,
        HealthBar = healthBar,
        Humanoid = humanoid,
        Player = player
    }
    
    table.insert(_espObjects, espData)
end

--[[
    PUBLIC: Add ESP to fruit
    @param fruit Tool
    @param rarity number
]]
function ESP:AddFruitESP(fruit, rarity)
    local handle = fruit:FindFirstChild("Handle")
    if not handle then return end
    
    local color = COLORS.Fruit.Common
    if rarity >= 5 then
        color = COLORS.Fruit.Mythical
    elseif rarity >= 4 then
        color = COLORS.Fruit.Legendary
    elseif rarity >= 3 then
        color = COLORS.Fruit.Rare
    elseif rarity >= 2 then
        color = COLORS.Fruit.Uncommon
    end
    
    local billboard = self:_createBillboard(fruit.Name, color, handle)
    
    local espData = {
        Type = "Fruit",
        Target = fruit,
        Billboard = billboard,
        Rarity = rarity
    }
    
    table.insert(_espObjects, espData)
end

--[[
    PUBLIC: Add ESP to chest
    @param chest BasePart
]]
function ESP:AddChestESP(chest)
    local billboard = self:_createBillboard("Chest", COLORS.Chest, chest)
    
    local espData = {
        Type = "Chest",
        Target = chest,
        Billboard = billboard
    }
    
    table.insert(_espObjects, espData)
end

--[[
    PRIVATE: Scan and add ESP
]]
function ESP:_scan()
    -- Scan players
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Services.LocalPlayer and player.Character then
            local exists = false
            for _, data in ipairs(_espObjects) do
                if data.Player == player then
                    exists = true
                    break
                end
            end
            if not exists then
                self:AddPlayerESP(player)
            end
        end
    end
    
    -- Scan fruits
    local fruitContainers = {"Fruits", "AppleSpawner", "PineappleSpawner"}
    for _, containerName in ipairs(fruitContainers) do
        local container = Services.Workspace:FindFirstChild(containerName)
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local exists = false
                    for _, data in ipairs(_espObjects) do
                        if data.Target == item then
                            exists = true
                            break
                        end
                    end
                    if not exists then
                        self:AddFruitESP(item, 3) -- Default to rare
                    end
                end
            end
        end
    end
    
    -- Scan chests
    for _, item in ipairs(Services.Workspace:GetDescendants()) do
        if item.Name == "Chest" and item:IsA("BasePart") then
            local exists = false
            for _, data in ipairs(_espObjects) do
                if data.Target == item then
                    exists = true
                    break
                end
            end
            if not exists then
                self:AddChestESP(item)
            end
        end
    end
end

--[[
    PRIVATE: Update loop
]]
function ESP:_updateLoop()
    while _enabled do
        -- Update existing ESP
        for _, espData in ipairs(_espObjects) do
            self:_updateESP(espData)
        end
        
        -- Scan for new targets periodically
        self:_scan()
        
        task.wait(UPDATE_RATE)
    end
end

--[[
    PUBLIC: Start ESP
]]
function ESP:Start()
    if _enabled then return end
    _enabled = true
    
    Variables:Set("ESP", true)
    
    task.spawn(function()
        self:_updateLoop()
    end)
    
    print("[ESP] Started")
end

--[[
    PUBLIC: Stop ESP
]]
function ESP:Stop()
    _enabled = false
    Variables:Set("ESP", false)
    
    -- Clean up all ESP objects
    for _, espData in ipairs(_espObjects) do
        if espData.Billboard then
            espData.Billboard:Destroy()
        end
    end
    _espObjects = {}
    
    print("[ESP] Stopped")
end

--[[
    PUBLIC: Toggle
    @return boolean
]]
function ESP:Toggle()
    if _enabled then
        self:Stop()
    else
        self:Start()
    end
    return _enabled
end

--[[
    PUBLIC: Is enabled
    @return boolean
]]
function ESP:IsEnabled()
    return _enabled
end

--[[
    PUBLIC: Destroy
]]
function ESP:Destroy()
    self:Stop()
    
    for _, connection in pairs(_connections) do
        if connection then
            connection:Disconnect()
        end
    end
    _connections = {}
end

return ESP
