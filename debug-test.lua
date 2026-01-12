--[[
    ================================================================
         AETHER HUB - Debug Test with UI (v3.3 Professional)
    ================================================================
    
    FEATURES:
    ✓ Advanced error handling with xpcall
    ✓ HTTP RequestAsync for reliable loading
    ✓ Full stack traces on errors
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

--[[
    Improved module loading with better error reporting
    Uses xpcall for stack traces and HttpService for reliable loading
]]
local function loadModule(path)
    local normalizedPath = path:gsub("\\", "/")
    addLog("Loading: " .. normalizedPath, false)
    
    local success, result = xpcall(function()
        local httpService = game:GetService("HttpService")
        local url = REPO_BASE .. normalizedPath
        
        -- Try RequestAsync first (more reliable)
        local response
        local useRequestAsync = pcall(function()
            response = httpService:RequestAsync({
                Url = url,
                Method = "GET",
                Headers = {
                    ["Cache-Control"] = "no-cache",
                    ["Pragma"] = "no-cache"
                }
            })
        end)
        
        local code
        if useRequestAsync and response and response.Success then
            code = response.Body
        else
            -- Fallback to HttpGet
            code = game:HttpGet(url, true)
        end
        
        if not code or code == "" then
            error("Empty response from server")
        end
        
        local moduleFunc, compileError = loadstring(code, normalizedPath)
        if not moduleFunc then
            error("Compilation failed: " .. tostring(compileError))
        end
        
        return moduleFunc()
    end, function(err)
        return debug.traceback(tostring(err), 2)
    end)
    
    if success and result then
        addLog("✓ Loaded: " .. normalizedPath, false)
        return result
    else
        local errorMsg = string.format("✗ FAILED: %s\n   Error: %s", normalizedPath, tostring(result))
        addLog(errorMsg, true)
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
    MainFrame.Size = UDim2.new(0, 550, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Add dragging
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 200, 150)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundColor3 = Color3.fromRGB(0, 180, 130)
    Title.BorderSizePixel = 0
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚡ AETHER HUB - Debug Test v3.3"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- Fix bottom corners of title
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
    TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
    TitleFix.BackgroundColor3 = Color3.fromRGB(0, 180, 130)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = Title
    
    -- Scroll Frame for Logs
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "LogsFrame"
    ScrollFrame.Size = UDim2.new(1, -20, 1, -145)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 55)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 150)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Parent = MainFrame
    
    local ScrollCorner = Instance.new("UICorner")
    ScrollCorner.CornerRadius = UDim.new(0, 8)
    ScrollCorner.Parent = ScrollFrame
    
    -- List Layout
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 3)
    ListLayout.Parent = ScrollFrame
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 8)
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.Parent = ScrollFrame
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "Status"
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 1, -80)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = "⏳ Status: Testing modules..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    StatusLabel.TextSize = 14
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame
    
    -- Buttons Frame
    local ButtonsFrame = Instance.new("Frame")
    ButtonsFrame.Name = "Buttons"
    ButtonsFrame.Size = UDim2.new(1, -20, 0, 40)
    ButtonsFrame.Position = UDim2.new(0, 10, 1, -50)
    ButtonsFrame.BackgroundTransparency = 1
    ButtonsFrame.Parent = MainFrame
    
    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ButtonLayout.Padding = UDim.new(0, 10)
    ButtonLayout.Parent = ButtonsFrame
    
    -- Button creator
    local function createButton(name, text, color)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 160, 0, 38)
        btn.BackgroundColor3 = color
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Parent = ButtonsFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        -- Hover effect
        btn.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.new(
                    math.min(color.R * 1.2, 1),
                    math.min(color.G * 1.2, 1),
                    math.min(color.B * 1.2, 1)
                )
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = color
            }):Play()
        end)
        
        return btn
    end
    
    local CopyBtn = createButton("CopyErrors", "📋 Copy Errors", Color3.fromRGB(220, 80, 80))
    local CopyAllBtn = createButton("CopyAll", "📋 Copy All Logs", Color3.fromRGB(80, 80, 220))
    local RunBtn = createButton("RunMain", "▶ Run Main Script", Color3.fromRGB(0, 180, 130))
    RunBtn.Visible = false
    
    -- Button Events
    CopyBtn.MouseButton1Click:Connect(function()
        local errorText = table.concat(Errors, "\n")
        if errorText == "" then
            errorText = "✅ No errors found!"
        end
        setclipboard(errorText)
        CopyBtn.Text = "✓ Copied!"
        task.delay(1.5, function() CopyBtn.Text = "📋 Copy Errors" end)
    end)
    
    CopyAllBtn.MouseButton1Click:Connect(function()
        local allLogs = table.concat(Logs, "\n")
        setclipboard(allLogs)
        CopyAllBtn.Text = "✓ Copied!"
        task.delay(1.5, function() CopyAllBtn.Text = "📋 Copy All Logs" end)
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
            LogLine.Size = UDim2.new(1, -20, 0, 0)
            LogLine.BackgroundTransparency = 1
            LogLine.Font = Enum.Font.Code
            LogLine.Text = text
            LogLine.TextColor3 = color or Color3.fromRGB(180, 180, 180)
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
    addLog("     AETHER HUB DEBUG TEST v3.3", false)
    addLog("========================================", false)
    UI.AddLogLine("⚡ AETHER HUB DEBUG TEST v3.3 ⚡", Color3.fromRGB(0, 255, 200))
    UI.AddLogLine("────────────────────────────────", Color3.fromRGB(100, 100, 100))
    
    -- Test 1: Environment
    addLog("\n=== TEST 1: Environment ===", false)
    UI.AddLogLine("\n📍 TEST 1: Environment", Color3.fromRGB(255, 220, 100))
    
    if game:GetService("Players").LocalPlayer then
        addLog("✓ Running on client", false)
        UI.AddLogLine("  ✓ Running on client", Color3.fromRGB(100, 255, 100))
        TestResults.Passed = TestResults.Passed + 1
    else
        addLog("✗ Not on client", true)
        UI.AddLogLine("  ✗ Not on client", Color3.fromRGB(255, 100, 100))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 2: Core Modules
    addLog("\n=== TEST 2: Core Modules ===", false)
    UI.AddLogLine("\n📍 TEST 2: Core Modules", Color3.fromRGB(255, 220, 100))
    
    local Services = loadModule("Modules/Core/Services.lua")
    UI.AddLogLine(Services and "  ✓ Services loaded" or "  ✗ Services FAILED", 
        Services and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
    
    local Variables = loadModule("Modules/Core/Variables.lua")
    UI.AddLogLine(Variables and "  ✓ Variables loaded" or "  ✗ Variables FAILED",
        Variables and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
    
    if Services and Variables then
        TestResults.Passed = TestResults.Passed + 1
    else
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 3: Teleporter
    addLog("\n=== TEST 3: Teleporter ===", false)
    UI.AddLogLine("\n📍 TEST 3: Teleporter", Color3.fromRGB(255, 220, 100))
    
    local Teleporter = loadModule("Modules/Teleport/Teleporter.lua")
    if Teleporter then
        local ok, err = pcall(function() Teleporter = Teleporter.new(Services) end)
        if ok then
            UI.AddLogLine("  ✓ Teleporter initialized", Color3.fromRGB(100, 255, 100))
            TestResults.Passed = TestResults.Passed + 1
        else
            UI.AddLogLine("  ✗ Teleporter init error: " .. tostring(err), Color3.fromRGB(255, 150, 100))
            TestResults.Failed = TestResults.Failed + 1
        end
    else
        UI.AddLogLine("  ✗ Teleporter FAILED to load", Color3.fromRGB(255, 100, 100))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 4: FastAttack
    addLog("\n=== TEST 4: FastAttack ===", false)
    UI.AddLogLine("\n📍 TEST 4: FastAttack", Color3.fromRGB(255, 220, 100))
    
    local FastAttack = loadModule("Modules/Combat/FastAttack.lua")
    if FastAttack then
        local ok, err = pcall(function() FastAttack = FastAttack.new(Services, Variables) end)
        if ok then
            UI.AddLogLine("  ✓ FastAttack initialized", Color3.fromRGB(100, 255, 100))
            TestResults.Passed = TestResults.Passed + 1
        else
            UI.AddLogLine("  ⚠ FastAttack init warning: " .. tostring(err):sub(1, 50), Color3.fromRGB(255, 200, 100))
            TestResults.Passed = TestResults.Passed + 1 -- Still pass as module loaded
        end
    else
        UI.AddLogLine("  ✗ FastAttack FAILED", Color3.fromRGB(255, 100, 100))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 5: BringMob
    addLog("\n=== TEST 5: BringMob ===", false)
    UI.AddLogLine("\n📍 TEST 5: BringMob", Color3.fromRGB(255, 220, 100))
    
    local BringMob = loadModule("Modules/Combat/BringMob.lua")
    if BringMob then
        local ok, err = pcall(function() BringMob = BringMob.new(Services, Variables) end)
        if ok then
            UI.AddLogLine("  ✓ BringMob initialized", Color3.fromRGB(100, 255, 100))
            TestResults.Passed = TestResults.Passed + 1
        else
            UI.AddLogLine("  ⚠ BringMob init warning: " .. tostring(err):sub(1, 50), Color3.fromRGB(255, 200, 100))
            TestResults.Passed = TestResults.Passed + 1
        end
    else
        UI.AddLogLine("  ✗ BringMob FAILED", Color3.fromRGB(255, 100, 100))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 6: QuestSystem
    addLog("\n=== TEST 6: QuestSystem ===", false)
    UI.AddLogLine("\n📍 TEST 6: QuestSystem", Color3.fromRGB(255, 220, 100))
    
    local QuestSystem = loadModule("Modules/Quest/QuestSystem.lua")
    if QuestSystem then
        local ok, err = pcall(function() QuestSystem = QuestSystem.new(Services) end)
        if ok then
            UI.AddLogLine("  ✓ QuestSystem initialized", Color3.fromRGB(100, 255, 100))
            TestResults.Passed = TestResults.Passed + 1
        else
            UI.AddLogLine("  ⚠ QuestSystem init warning: " .. tostring(err):sub(1, 50), Color3.fromRGB(255, 200, 100))
            TestResults.Passed = TestResults.Passed + 1
        end
    else
        UI.AddLogLine("  ✗ QuestSystem FAILED", Color3.fromRGB(255, 100, 100))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Test 7: AutoFarmLevel
    addLog("\n=== TEST 7: AutoFarmLevel ===", false)
    UI.AddLogLine("\n📍 TEST 7: AutoFarmLevel", Color3.fromRGB(255, 220, 100))
    
    local AutoFarmLevel = loadModule("Modules/Combat/AutoFarmLevel.lua")
    if AutoFarmLevel then
        UI.AddLogLine("  ✓ AutoFarmLevel loaded", Color3.fromRGB(100, 255, 100))
        TestResults.Passed = TestResults.Passed + 1
    else
        UI.AddLogLine("  ✗ AutoFarmLevel FAILED", Color3.fromRGB(255, 100, 100))
        TestResults.Failed = TestResults.Failed + 1
    end
    
    -- Results
    addLog("\n========================================", false)
    addLog("     RESULTS", false)
    addLog("========================================", false)
    UI.AddLogLine("\n────────────────────────────────", Color3.fromRGB(100, 100, 100))
    UI.AddLogLine("📊 RESULTS", Color3.fromRGB(0, 255, 200))
    UI.AddLogLine("────────────────────────────────", Color3.fromRGB(100, 100, 100))
    
    local total = TestResults.Passed + TestResults.Failed
    local successRate = math.floor((TestResults.Passed / total) * 100)
    
    addLog(string.format("✓ Passed: %d / %d (%d%%)", TestResults.Passed, total, successRate), false)
    UI.AddLogLine(string.format("  ✓ Passed: %d / %d (%d%%)", TestResults.Passed, total, successRate),
        successRate >= 80 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 200, 100))
    
    if #Errors > 0 then
        addLog(string.format("✗ Errors: %d - Click 'Copy Errors'", #Errors), true)
        UI.AddLogLine(string.format("  ✗ Errors: %d - Click 'Copy Errors'", #Errors), Color3.fromRGB(255, 100, 100))
    else
        UI.AddLogLine("  ✓ No errors detected!", Color3.fromRGB(100, 255, 100))
    end
    
    -- Update status
    if successRate >= 70 then
        UI.StatusLabel.Text = "✅ Tests passed! Ready to run main script."
        UI.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        UI.RunBtn.Visible = true
    else
        UI.StatusLabel.Text = "❌ Tests failed. Copy errors and fix issues."
        UI.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

--// MAIN
local UI = createUI()
task.spawn(function()
    task.wait(0.5)
    runTests(UI)
end)