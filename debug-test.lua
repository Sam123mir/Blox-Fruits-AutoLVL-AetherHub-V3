--[[
    AETHER HUB - Debug Test (v3.1 - Simplified)
    Quick test to verify modules load correctly
]]

local REPO_BASE = "https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/"

-- Utilities
local function log(level, msg)
    local prefix = {
        INFO = "[INFO]",
        PASS = "[✓]",
        FAIL = "[✗]",
        WARN = "[!]"
    }
    print(string.format("%s %s", prefix[level] or "[?]", msg))
end

local function loadModule(path)
    log("INFO", "Loading: " .. path)
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(REPO_BASE .. path))()
    end)
    
    if success and result then
        log("PASS", "Loaded: " .. path)
        return result
    else
        log("FAIL", "Failed: " .. path .. " - " .. tostring(result))
        return nil
    end
end

-- Main Test
print("\n" .. string.rep("=", 50))
print("     AETHER HUB - DEBUG TEST v3.1")
print(string.rep("=", 50))

local passed = 0
local failed = 0

-- Test 1: Environment
log("INFO", "\n=== TEST 1: Environment ===")
if game:GetService("Players").LocalPlayer then
    log("PASS", "Running on client")
    passed = passed + 1
else
    log("FAIL", "Not on client")
    failed = failed + 1
end

-- Test 2: Core Modules
log("INFO", "\n=== TEST 2: Core Modules ===")
local Services = loadModule("Modules/Core/Services.lua")
local Variables = loadModule("Modules/Core/Variables.lua")

if Services and Services.LocalPlayer then
    log("PASS", "Services loaded with LocalPlayer")
    passed = passed + 1
else
    log("FAIL", "Services failed")
    failed = failed + 1
end

if Variables then
    log("PASS", "Variables loaded - World: " .. tostring(Variables.World))
    passed = passed + 1
else
    log("FAIL", "Variables failed")
    failed = failed + 1
end

-- Test 3: Teleporter
log("INFO", "\n=== TEST 3: Teleporter ===")
local Teleporter = loadModule("Modules/Teleport/Teleporter.lua")

if Teleporter then
    local tp = Teleporter.new(Services)
    if tp and tp.TeleportTo then
        log("PASS", "Teleporter initialized")
        passed = passed + 1
    else
        log("FAIL", "Teleporter missing methods")
        failed = failed + 1
    end
else
    log("FAIL", "Teleporter failed to load")
    failed = failed + 1
end

-- Test 4: Feature Modules
log("INFO", "\n=== TEST 4: Feature Modules ===")
local FruitFinder = loadModule("Modules/Fruit/FruitFinder.lua")
local FruitStorage = loadModule("Modules/Fruit/FruitStorage.lua")
local AutoFarm = loadModule("Modules/Combat/AutoFarm.lua")

local featuresLoaded = 0
if FruitFinder then 
    FruitFinder.new(Services)
    featuresLoaded = featuresLoaded + 1 
end
if FruitStorage then 
    FruitStorage.new(Services)
    featuresLoaded = featuresLoaded + 1 
end
if AutoFarm then 
    local tp = Teleporter.new(Services)
    AutoFarm.new(Services, Variables, tp)
    featuresLoaded = featuresLoaded + 1 
end

if featuresLoaded >= 2 then
    log("PASS", "Features loaded: " .. featuresLoaded .. "/3")
    passed = passed + 1
else
    log("FAIL", "Only " .. featuresLoaded .. "/3 features loaded")
    failed = failed + 1
end

-- Test 5: Variables Set/Get
log("INFO", "\n=== TEST 5: Variables ===")
if Variables then
    Variables:Set("AutoFarm", true)
    if Variables:Get("AutoFarm") == true then
        log("PASS", "Variables Set/Get works")
        passed = passed + 1
    else
        log("FAIL", "Variables Set/Get failed")
        failed = failed + 1
    end
    Variables:Set("AutoFarm", false)
else
    log("FAIL", "Variables not loaded")
    failed = failed + 1
end

-- Test 6: Main Script
log("INFO", "\n=== TEST 6: Main Script ===")
local mainSuccess = pcall(function()
    loadstring(game:HttpGet(REPO_BASE .. "main.lua"))()
end)

if mainSuccess then
    log("PASS", "Main script loaded successfully")
    passed = passed + 1
else
    log("FAIL", "Main script failed")
    failed = failed + 1
end

-- Results
print("\n" .. string.rep("=", 50))
print("     RESULTS")
print(string.rep("=", 50))
log("PASS", "Passed: " .. passed)
log("FAIL", "Failed: " .. failed)
log("INFO", "Success Rate: " .. math.floor((passed / (passed + failed)) * 100) .. "%")
print(string.rep("=", 50))

if failed == 0 then
    log("PASS", "ALL TESTS PASSED!")
else
    log("WARN", "Some tests failed - check logs above")
end