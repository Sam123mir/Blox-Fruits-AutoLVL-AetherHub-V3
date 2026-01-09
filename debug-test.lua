--[[
    AETHER HUB - Debug Test
    Usa esto para verificar si el script carga
]]

print("═══════════════════════════════════════")
print("       AETHER HUB - DEBUG TEST")
print("═══════════════════════════════════════")

-- Test 1: Verificar HttpGet
print("[TEST 1] Probando HttpGet...")
local success1, result1 = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/blox-fruits.lua")
end)

if success1 then
    print("[TEST 1] ✅ HttpGet funcionando - Script tiene " .. #result1 .. " caracteres")
else
    print("[TEST 1] ❌ Error en HttpGet: " .. tostring(result1))
    return
end

-- Test 2: Verificar loadstring
print("[TEST 2] Probando loadstring del script...")
local func, syntaxError = loadstring(result1)

if func then
    print("[TEST 2] ✅ loadstring funcionando")
else
    print("[TEST 2] ❌ ERROR DE SINTAXIS:")
    print(tostring(syntaxError))
    return
end

-- Test 3: Ejecutar el script
print("[TEST 3] Ejecutando script...")
local success3, result3 = pcall(result2)

if success3 then
    print("[TEST 3] ✅ Script ejecutado correctamente")
else
    print("[TEST 3] ❌ Error al ejecutar: " .. tostring(result3))
end

print("═══════════════════════════════════════")
print("       DEBUG TEST COMPLETADO")
print("═══════════════════════════════════════")
