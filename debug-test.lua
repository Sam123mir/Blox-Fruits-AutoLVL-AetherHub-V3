--[[
    ================================================================
         AETHER HUB - Debug & Testing Suite (v3.0)
    ================================================================
    
    PROFESSIONAL TESTING SYSTEM:
    ✓ Module loading verification
    ✓ Dependency injection testing
    ✓ Performance benchmarking
    ✓ Error logging
    ✓ Health checks
    ✓ Integration tests
]]

--// CONFIGURATION
local REPO_BASE = "https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/"
local TEST_TIMEOUT = 30 -- seconds
local VERBOSE_MODE = true

--// TEST RESULTS
local TestResults = {
    Passed = 0,
    Failed = 0,
    Skipped = 0,
    TotalTime = 0,
    Details = {}
}

--// UTILITIES
local function printHeader(text)
    print("\n" .. string.rep("=", 60))
    print("         " .. text)
    print(string.rep("=", 60))
end

local function printSection(text)
    print("\n" .. string.rep("-", 60))
    print("  " .. text)
    print(string.rep("-", 60))
end

local function log(level, message)
    local prefix = {
        INFO = "[ℹ INFO]",
        SUCCESS = "[✓ PASS]",
        ERROR = "[✗ FAIL]",
        WARN = "[⚠ WARN]",
        SKIP = "[⊘ SKIP]"
    }
    
    print(string.format("%s %s", prefix[level] or "[?]", message))
end

--[[
    Test Class
]]
local Test = {}
Test.__index = Test

function Test.new(name, testFunc, options)
    local self = setmetatable({}, Test)
    self.Name = name
    self.TestFunc = testFunc
    self.Options = options or {}
    self.StartTime = 0
    self.EndTime = 0
    self.Status = "Pending"
    self.Error = nil
    return self
end

function Test:Run()
    self.StartTime = tick()
    
    log("INFO", string.format("Running: %s", self.Name))
    
    local success, result = pcall(function()
        return self.TestFunc()
    end)
    
    self.EndTime = tick()
    local duration = self.EndTime - self.StartTime
    
    if success then
        if result ~= false then
            self.Status = "Passed"
            TestResults.Passed = TestResults.Passed + 1
            log("SUCCESS", string.format("%s (%.3fs)", self.Name, duration))
        else
            self.Status = "Failed"
            TestResults.Failed = TestResults.Failed + 1
            self.Error = "Test returned false"
            log("ERROR", string.format("%s - %s", self.Name, self.Error))
        end
    else
        self.Status = "Failed"
        TestResults.Failed = TestResults.Failed + 1
        self.Error = tostring(result)
        log("ERROR", string.format("%s - %s", self.Name, self.Error))
    end
    
    -- Store results
    table.insert(TestResults.Details, {
        Name = self.Name,
        Status = self.Status,
        Duration = duration,
        Error = self.Error
    })
    
    TestResults.TotalTime = TestResults.TotalTime + duration
    
    return self.Status == "Passed"
end

--[[
    Test Suite
]]
local function loadModule(path)
    local url = REPO_BASE .. path
    log("INFO", string.format("Loading: %s", path))
    
    local success, result = pcall(function()
        local code = game:HttpGet(url, true)
        local moduleFunc = loadstring(code)
        
        if not moduleFunc then
            error("Failed to compile module")
        end
        
        return moduleFunc()
    end)
    
    if success then
        log("SUCCESS", string.format("Loaded: %s", path))
        return result
    else
        log("ERROR", string.format("Failed: %s - %s", path, tostring(result)))
        return nil
    end
end

--[[
    TESTS DEFINITION
]]
local Tests = {}

-- TEST 1: Environment Check
table.insert(Tests, Test.new("Environment Check", function()
    -- Check if client side
    if not game:GetService("Players").LocalPlayer then
        error("Must run on client")
    end
    
    -- Check place ID
    local validPlaceIds = {2753915549, 4442272183, 7449423635}
    local isValid = false
    
    for _, id in ipairs(validPlaceIds) do
        if game.PlaceId == id then
            isValid = true
            break
        end
    end
    
    if not isValid then
        log("WARN", "Not in Blox Fruits (PlaceId: " .. game.PlaceId .. ")")
    end
    
    return true
end))

-- TEST 2: Load Core Modules
table.insert(Tests, Test.new("Core Modules Loading", function()
    local Services = loadModule("Modules/Core/Services.lua")
    local Variables = loadModule("Modules/Core/Variables.lua")
    
    if not Services then error("Services failed to load") end
    if not Variables then error("Variables failed to load") end
    
    -- Validate Services
    if not Services.Players or not Services.Workspace then
        error("Services missing required references")
    end
    
    -- Validate Variables
    if not Variables.World then
        error("Variables not initialized properly")
    end
    
    log("INFO", string.format("  World: %s", Variables.World))
    
    return true
end))

-- TEST 3: Load Utility Modules
table.insert(Tests, Test.new("Utility Modules Loading", function()
    local Services = loadModule("Modules/Core/Services.lua")
    local Teleporter = loadModule("Modules/Teleport/Teleporter.lua")
    
    if not Teleporter then error("Teleporter failed to load") end
    
    -- Test instantiation
    local tp = Teleporter.new(Services)
    if not tp then error("Failed to instantiate Teleporter") end
    
    -- Test methods exist
    if not tp.TeleportTo or not tp.TeleportToPosition then
        error("Teleporter missing required methods")
    end
    
    return true
end))

-- TEST 4: Load Feature Modules
table.insert(Tests, Test.new("Feature Modules Loading", function()
    local Services = loadModule("Modules/Core/Services.lua")
    local Variables = loadModule("Modules/Core/Variables.lua")
    local Teleporter = loadModule("Modules/Teleport/Teleporter.lua")
    
    local FruitFinder = loadModule("Modules/Fruit/FruitFinder.lua")
    local FruitStorage = loadModule("Modules/Fruit/FruitStorage.lua")
    local AutoFarm = loadModule("Modules/Combat/AutoFarm.lua")
    
    if not FruitFinder then log("WARN", "FruitFinder failed") end
    if not FruitStorage then log("WARN", "FruitStorage failed") end
    if not AutoFarm then log("WARN", "AutoFarm failed") end
    
    -- At least one feature module should load
    return FruitFinder ~= nil or FruitStorage ~= nil or AutoFarm ~= nil
end))

-- TEST 5: Dependency Injection
table.insert(Tests, Test.new("Dependency Injection", function()
    local Services = loadModule("Modules/Core/Services.lua")
    local Variables = loadModule("Modules/Core/Variables.lua")
    local Teleporter = loadModule("Modules/Teleport/Teleporter.lua")
    local AutoFarm = loadModule("Modules/Combat/AutoFarm.lua")
    
    if not AutoFarm then return false end
    
    -- Test DI pattern
    local tp = Teleporter.new(Services)
    local farm = AutoFarm.new(Services, Variables, tp)
    
    if not farm then error("Failed to instantiate AutoFarm with dependencies") end
    
    -- Test methods
    if not farm.Start or not farm.Stop then
        error("AutoFarm missing required methods")
    end
    
    return true
end))

-- TEST 6: State Management
table.insert(Tests, Test.new("State Management", function()
    local Variables = loadModule("Modules/Core/Variables.lua")
    
    -- Test Set/Get
    Variables:Set("AutoFarm", true)
    if Variables:Get("AutoFarm") ~= true then
        error("Variable Set/Get failed")
    end
    
    -- Test validation
    local success = Variables:Set("FarmDistance", 150)
    if not success then
        error("Valid value rejected")
    end
    
    local invalidSuccess = Variables:Set("FarmDistance", 10000)
    if invalidSuccess then
        error("Invalid value accepted")
    end
    
    -- Test listener
    local callbackCalled = false
    local disconnect = Variables:OnChanged("AutoFarm", function()
        callbackCalled = true
    end)
    
    Variables:Set("AutoFarm", false)
    task.wait(0.1)
    
    if not callbackCalled then
        error("Listener not triggered")
    end
    
    disconnect()
    
    return true
end))

-- TEST 7: Performance Benchmark
table.insert(Tests, Test.new("Performance Benchmark", function()
    local Services = loadModule("Modules/Core/Services.lua")
    
    -- Benchmark GetHumanoidRootPart (cached)
    local iterations = 1000
    local startTime = tick()
    
    for i = 1, iterations do
        Services:GetHumanoidRootPart()
    end
    
    local duration = tick() - startTime
    local avgTime = duration / iterations
    
    log("INFO", string.format("  Average HRP fetch: %.6fs", avgTime))
    
    -- Should be fast due to caching
    if avgTime > 0.001 then
        log("WARN", "Performance slower than expected")
    end
    
    return true
end))

-- TEST 8: Main Script Load
table.insert(Tests, Test.new("Main Script Loading", function()
    local success, error = pcall(function()
        loadstring(game:HttpGet(REPO_BASE .. "main.lua"))()
    end)
    
    if not success then
        log("ERROR", tostring(error))
        return false
    end
    
    return true
end))

--[[
    RUN ALL TESTS
]]
local function runTests()
    printHeader("AETHER HUB - TESTING SUITE v3.0")
    
    log("INFO", string.format("Starting %d tests...", #Tests))
    log("INFO", string.format("Repository: %s", REPO_BASE))
    log("INFO", string.format("Place: %s (%d)", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, game.PlaceId))
    
    -- Run all tests
    for i, test in ipairs(Tests) do
        printSection(string.format("TEST %d/%d", i, #Tests))
        test:Run()
        task.wait(0.1) -- Small delay between tests
    end
    
    -- Print results
    printHeader("TEST RESULTS")
    
    log("SUCCESS", string.format("Passed: %d", TestResults.Passed))
    log("ERROR", string.format("Failed: %d", TestResults.Failed))
    log("SKIP", string.format("Skipped: %d", TestResults.Skipped))
    log("INFO", string.format("Total Time: %.3fs", TestResults.TotalTime))
    
    -- Detailed results
    if TestResults.Failed > 0 then
        printSection("FAILED TESTS")
        for _, detail in ipairs(TestResults.Details) do
            if detail.Status == "Failed" then
                log("ERROR", string.format("%s - %s", detail.Name, detail.Error or "Unknown"))
            end
        end
    end
    
    -- Summary
    printHeader("SUMMARY")
    
    local successRate = (TestResults.Passed / #Tests) * 100
    log("INFO", string.format("Success Rate: %.1f%%", successRate))
    
    if successRate == 100 then
        log("SUCCESS", "All tests passed! ✓")
    elseif successRate >= 80 then
        log("WARN", "Most tests passed, but some issues detected")
    else
        log("ERROR", "Critical failures detected!")
    end
    
    printHeader("TEST COMPLETE")
    
    return successRate >= 80
end

--[[
    EXECUTE
]]
local overallSuccess = pcall(runTests)

if not overallSuccess then
    printHeader("FATAL ERROR")
    log("ERROR", "Testing suite crashed!")
end