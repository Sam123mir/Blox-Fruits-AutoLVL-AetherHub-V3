--[[
    ================================================================
         AETHER HUB - Debug Test with UI (v3.2)
    ================================================================
    
    FEATURES:
    ✓ Tests all modules
    ✓ UI to display logs
    ✓ Copy errors to clipboard
    ✓ Auto-run main script if all tests pass
]]

local REPO_BASE = "https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/"

--// LOG STORAGE
local Logs = {}
local Errors = {}
local TestResults = {Passed = 0, Failed = 0}

--// UTILITIES
local function addLog(message, isError)
    local timestamp = os.date("%H:%M:%S")
    local logEntry = string.format("[%s] %s", timestamp, message)
    
    table.insert(Logs, logEntry)
    
    if isError then
        table.insert(Errors, logEntry)
    end
    
    print(logEntry)
end

local function loadModule(path)
    addLog("Loading: " .. path, false)
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(REPO_BASE .. path))()
    end)
    
    if success and result then
        addLog("✓ Loaded: " .. path, false)
        return result
    else
        addLog("✗ FAILED: " .. path .. " - " .. tostring(result), true)
        return nil
    end
end

--// CREATE UI
local function createUI()
    -- Destroy existing
    local existing = game.CoreGui:FindFirstChild("AetherDebugUI")
    if existing then existing:Destroy() end
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AetherDebugUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game.CoreGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
    Title.BorderSizePixel = 0
    Title.Font = Enum.Font.GothamBold
    Title.Text = "AETHER HUB - Debug Test v3.2"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Scroll Frame for Logs
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "LogsFrame"
    ScrollFrame.Size = UDim2.new(1, -20, 1, -130)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Parent = MainFrame
    
    local ScrollCorner = Instance.new("UICorner")
    ScrollCorner.CornerRadius = UDim.new(0, 5)
    ScrollCorner.Parent = ScrollFrame
    
    -- List Layout
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = ScrollFrame
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "Status"
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 1, -70)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = "Status: Testing..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    StatusLabel.TextSize = 14
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame
    
    -- Buttons Frame
    local ButtonsFrame = Instance.new("Frame")
    ButtonsFrame.Name = "Buttons"
    ButtonsFrame.Size = UDim2.new(1, -20, 0, 35)
    ButtonsFrame.Position = UDim2.new(0, 10, 1, -40)
    ButtonsFrame.BackgroundTransparency = 1
    ButtonsFrame.Parent = MainFrame
    
    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ButtonLayout.Padding = UDim.new(0, 10)
    ButtonLayout.Parent = ButtonsFrame
    
    -- Copy Errors Button
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Name = "CopyErrors"
    CopyBtn.Size = UDim2.new(0, 150, 0, 35)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.Text = "📋 Copy Errors"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.TextSize = 14
    CopyBtn.Parent = ButtonsFrame
    
    local CopyCorner = Instance.new("UICorner")
    CopyCorner.CornerRadius = UDim.new(0, 5)
    CopyCorner.Parent = CopyBtn
    
    -- Copy All Button
    local CopyAllBtn = Instance.new("TextButton")
    CopyAllBtn.Name = "CopyAll"
    CopyAllBtn.Size = UDim2.new(0, 150, 0, 35)
    CopyAllBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    CopyAllBtn.Font = Enum.Font.GothamBold
    CopyAllBtn.Text = "📋 Copy All Logs"
    CopyAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyAllBtn.TextSize = 14
    CopyAllBtn.Parent = ButtonsFrame
    
    local CopyAllCorner = Instance.new("UICorner")
    CopyAllCorner.CornerRadius = UDim.new(0, 5)
    CopyAllCorner.Parent = CopyAllBtn
    
    -- Run Main Button
    local RunBtn = Instance.new("TextButton")
    RunBtn.Name = "RunMain"
    RunBtn.Size = UDim2.new(0, 150, 0, 35)
    RunBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
    RunBtn.Font = Enum.Font.GothamBold
    RunBtn.Text = "▶ Run Main Script"
    RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RunBtn.TextSize = 14
    RunBtn.Visible = false
    RunBtn.Parent = ButtonsFrame
    
    local RunCorner = Instance.new("UICorner")
    RunCorner.CornerRadius = UDim.new(0, 5)
    RunCorner.Parent = RunBtn
    
    -- Button Events
    CopyBtn.MouseButton1Click:Connect(function()
        local errorText = table.concat(Errors, "\n")
        if errorText == "" then
            errorText = "No errors found!"
        end
        setclipboard(errorText)
        CopyBtn.Text = "✓ Copied!"
        task.wait(1)
        CopyBtn.Text = "📋 Copy Errors"
    end)
    
    CopyAllBtn.MouseButton1Click:Connect(function()
        local allLogs = table.concat(Logs, "\n")
        setclipboard(allLogs)
        CopyAllBtn.Text = "✓ Copied!"
        task.wait(1)
        CopyAllBtn.Text = "📋 Copy All Logs"
    end)
    
    RunBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        loadstring(game:HttpGet(REPO_BASE .. "main.lua"))()
    end)
    
    return {
        MainFrame = MainFrame,
        ScrollFrame = ScrollFrame,
        StatusLabel = StatusLabel,
        RunBtn = RunBtn,
        
        AddLogLine = function(text, color)
            local LogLine = Instance.new("TextLabel")
            LogLine.Size = UDim2.new(1, -10, 0, 18)
            LogLine.BackgroundTransparency = 1
            LogLine.Font = Enum.Font.Code
            LogLine.Text = text
            LogLine.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            LogLine.TextSize = 12
            LogLine.TextXAlignment = Enum.TextXAlignment.Left
            LogLine.TextWrapped = true
            LogLine.AutomaticSize = Enum.AutomaticSize.Y
            LogLine.Parent = ScrollFrame
        end
    }
end

--// RUN TESTS
local function runTests(UI)
    addLog("========================================", false)
    addLog("     AETHER HUB DEBUG TEST v3.2", false)
    addLog("========================================", false)
    UI.AddLogLine("========================================", Color3.fromRGB(0, 255, 200))
    UI.AddLogLine("     AETHER HUB DEBUG TEST v3.2", Color3.fromRGB(0, 255, 200))
    UI.AddLogLine("========================================", Color3.fromRGB(0, 255, 200))
    
    -- Test 1: Environment
    addLog("\n=== TEST 1: Environment ===", false)
    UI.AddLogLine("\n=== TEST 1: Environment ===", Color3.fromRGB(255, 255, 100))
    
    if game:GetService("Players").LocalPlayer then
        addLog("✓ Running on client", false)
        UI.AddLogLine("✓ Running on client", Color3.fromRGB(0, 255, 0))
        TestResults.Passed = TestResults.Passed + 1
    else
        addLog("✗ Not on client", true)
        UI.AddLogLine("✗ Not on client", Color3.fromRGB(255, 0, 0))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 2: Core Modules
    addLog("\n=== TEST 2: Core Modules ===", false)
    UI.AddLogLine("\n=== TEST 2: Core Modules ===", Color3.fromRGB(255, 255, 100))
    
    local Services = loadModule("Modules/Core/Services.lua")
    UI.AddLogLine(Services and "✓ Services loaded" or "✗ Services FAILED", 
        Services and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
    
    local Variables = loadModule("Modules/Core/Variables.lua")
    UI.AddLogLine(Variables and "✓ Variables loaded" or "✗ Variables FAILED",
        Variables and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
    
    if Services and Variables then
        TestResults.Passed = TestResults.Passed + 1
    else
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 3: Teleporter
    addLog("\n=== TEST 3: Teleporter ===", false)
    UI.AddLogLine("\n=== TEST 3: Teleporter ===", Color3.fromRGB(255, 255, 100))
    
    local Teleporter = loadModule("Modules/Teleport/Teleporter.lua")
    if Teleporter then
        Teleporter = Teleporter.new(Services)
        UI.AddLogLine("✓ Teleporter initialized", Color3.fromRGB(0, 255, 0))
        TestResults.Passed = TestResults.Passed + 1
    else
        UI.AddLogLine("✗ Teleporter FAILED", Color3.fromRGB(255, 0, 0))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 4: FastAttack
    addLog("\n=== TEST 4: FastAttack ===", false)
    UI.AddLogLine("\n=== TEST 4: FastAttack ===", Color3.fromRGB(255, 255, 100))
    
    local FastAttack = loadModule("Modules/Combat/FastAttack.lua")
    if FastAttack then
        local ok = pcall(function() FastAttack = FastAttack.new(Services, Variables) end)
        UI.AddLogLine(ok and "✓ FastAttack initialized" or "✗ FastAttack init error",
            ok and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 0))
        if ok then TestResults.Passed = TestResults.Passed + 1 else TestResults.Failed = TestResults.Failed + 1 end
    else
        UI.AddLogLine("✗ FastAttack FAILED", Color3.fromRGB(255, 0, 0))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 5: BringMob
    addLog("\n=== TEST 5: BringMob ===", false)
    UI.AddLogLine("\n=== TEST 5: BringMob ===", Color3.fromRGB(255, 255, 100))
    
    local BringMob = loadModule("Modules/Combat/BringMob.lua")
    if BringMob then
        local ok = pcall(function() BringMob = BringMob.new(Services, Variables) end)
        UI.AddLogLine(ok and "✓ BringMob initialized" or "✗ BringMob init error",
            ok and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 0))
        if ok then TestResults.Passed = TestResults.Passed + 1 else TestResults.Failed = TestResults.Failed + 1 end
    else
        UI.AddLogLine("✗ BringMob FAILED", Color3.fromRGB(255, 0, 0))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 6: QuestSystem
    addLog("\n=== TEST 6: QuestSystem ===", false)
    UI.AddLogLine("\n=== TEST 6: QuestSystem ===", Color3.fromRGB(255, 255, 100))
    
    local QuestSystem = loadModule("Modules/Quest/QuestSystem.lua")
    if QuestSystem then
        local ok = pcall(function() QuestSystem = QuestSystem.new(Services) end)
        UI.AddLogLine(ok and "✓ QuestSystem initialized" or "✗ QuestSystem init error",
            ok and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 0))
        if ok then TestResults.Passed = TestResults.Passed + 1 else TestResults.Failed = TestResults.Failed + 1 end
    else
        UI.AddLogLine("✗ QuestSystem FAILED", Color3.fromRGB(255, 0, 0))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 7: AutoFarmLevel
    addLog("\n=== TEST 7: AutoFarmLevel ===", false)
    UI.AddLogLine("\n=== TEST 7: AutoFarmLevel ===", Color3.fromRGB(255, 255, 100))
    
    local AutoFarmLevel = loadModule("Modules/Combat/AutoFarmLevel.lua")
    if AutoFarmLevel then
        UI.AddLogLine("✓ AutoFarmLevel loaded", Color3.fromRGB(0, 255, 0))
        TestResults.Passed = TestResults.Passed + 1
    else
        UI.AddLogLine("✗ AutoFarmLevel FAILED", Color3.fromRGB(255, 0, 0))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Results
    addLog("\n========================================", false)
    addLog("     RESULTS", false)
    addLog("========================================", false)
    UI.AddLogLine("\n========================================", Color3.fromRGB(0, 255, 200))
    UI.AddLogLine("     RESULTS", Color3.fromRGB(0, 255, 200))
    UI.AddLogLine("========================================", Color3.fromRGB(0, 255, 200))
    
    local total = TestResults.Passed + TestResults.Failed
    local successRate = math.floor((TestResults.Passed / total) * 100)
    
    addLog(string.format("Passed: %d / %d (%d%%)", TestResults.Passed, total, successRate), false)
    UI.AddLogLine(string.format("Passed: %d / %d (%d%%)", TestResults.Passed, total, successRate),
        successRate >= 80 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 0))
    
    if #Errors > 0 then
        addLog(string.format("Errors: %d (Click 'Copy Errors' to copy)", #Errors), true)
        UI.AddLogLine(string.format("Errors: %d - Click 'Copy Errors' to copy", #Errors), Color3.fromRGB(255, 0, 0))
    end
    
    -- Update status
    if successRate >= 80 then
        UI.StatusLabel.Text = "✓ Tests passed! Ready to run main script."
        UI.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        UI.RunBtn.Visible = true
    else
        UI.StatusLabel.Text = "✗ Tests failed. Copy errors and fix issues."
        UI.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
    end
end

--// MAIN
local UI = createUI()
task.spawn(function()
    task.wait(0.5)
    runTests(UI)
end)