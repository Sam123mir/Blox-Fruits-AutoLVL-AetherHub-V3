-- =====================================================
--           AETHER HUB - ENHANCED DEBUG TEST
-- =====================================================

print("==================================================")
print("         AETHER HUB - ADVANCED DEBUG MODE")
print("==================================================")

local errors = {}
local warnings = {}

local function logError(context, err)
    table.insert(errors, {context = context, error = tostring(err)})
    warn("[ERROR] " .. context .. ": " .. tostring(err))
end

local function logWarning(context, msg)
    table.insert(warnings, {context = context, message = msg})
    print("[WARNING] " .. context .. ": " .. msg)
end

-- TEST 1: HttpGet
print("")
print("[TEST 1] Probando HttpGet...")
local scriptUrl = "https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/blox-fruits.lua"
local scriptCode = nil
local httpSuccess, httpResult = pcall(function()
    return game:HttpGet(scriptUrl)
end)

if httpSuccess and httpResult then
    scriptCode = httpResult
    print("[TEST 1] ✅ HttpGet funcionando - Script tiene " .. #scriptCode .. " caracteres")
else
    logError("TEST 1 - HttpGet", httpResult)
    return
end

-- TEST 2: Loadstring (Syntax Check)
print("")
print("[TEST 2] Probando loadstring del script...")
local compiledFunc, syntaxError = loadstring(scriptCode)

if compiledFunc then
    print("[TEST 2] ✅ loadstring funcionando")
else
    logError("TEST 2 - loadstring", syntaxError or "Unknown syntax error")
    return
end

-- TEST 3: Execute with DETAILED error catching
print("")
print("[TEST 3] Ejecutando script con captura de errores mejorada...")
print("==================================================")

-- Wrap the entire execution to catch ALL errors
local mainSuccess, mainError = xpcall(function()
    
    -- Execute the script
    local executionSuccess, executionError = xpcall(compiledFunc, function(err)
        return debug.traceback("EXECUTION ERROR: " .. tostring(err), 2)
    end)
    
    if not executionSuccess then
        logError("MAIN EXECUTION", executionError)
        
        -- Try to extract line number from error
        local lineNum = string.match(executionError, ":(%d+):")
        if lineNum then
            print("\n📍 Error aproximado en línea: " .. lineNum)
        end
    end
    
end, function(err)
    return debug.traceback("CRITICAL ERROR: " .. tostring(err), 2)
end)

if not mainSuccess then
    logError("CRITICAL FAILURE", mainError)
end

-- REPORT ALL ERRORS
print("")
print("==================================================")
print("             DEBUG TEST COMPLETADO")
print("==================================================")

if #errors > 0 then
    print("\n❌ ERRORES ENCONTRADOS (" .. #errors .. "):")
    print("--------------------------------------------------")
    for i, errInfo in ipairs(errors) do
        print(string.format("[%d] %s", i, errInfo.context))
        print("    " .. errInfo.error)
        print("")
    end
else
    print("\n✅ ¡Sin errores detectados!")
end

if #warnings > 0 then
    print("\n⚠️  ADVERTENCIAS (" .. #warnings .. "):")
    print("--------------------------------------------------")
    for i, warnInfo in ipairs(warnings) do
        print(string.format("[%d] %s: %s", i, warnInfo.context, warnInfo.message))
    end
end

print("\n==================================================")
