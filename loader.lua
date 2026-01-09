--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                      AETHER HUB                               ║
    ║               Blox Fruits Script Loader                       ║
    ║     Compatible: Delta, Xeno, Solara, Fluxus, KRNL & more      ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    USO:
    ========================================================
    
    Opción 1 - Si subes el script a GitHub (RAW):
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/blox-fruits.lua"))()
    
    Opción 2 - Si subes a Pastebin:
    loadstring(game:HttpGet("https://pastebin.com/raw/TU_CODIGO"))()
    
    Opción 3 - Si tienes el archivo local:
    loadstring(readfile("blox-fruits.lua"))()
    
    ========================================================
]]

-- CAMBIA ESTA URL POR LA TUYA:
local SCRIPT_URL = "https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/blox-fruits.lua"

-- Loader con manejo de errores
local success, result = pcall(function()
    return game:HttpGet(SCRIPT_URL)
end)

if success then
    local loadSuccess, loadError = pcall(function()
        loadstring(result)()
    end)
    
    if not loadSuccess then
        warn("═══════════════════════════════════════")
        warn("AETHER HUB - Error al cargar script:")
        warn(tostring(loadError))
        warn("═══════════════════════════════════════")
    end
else
    warn("═══════════════════════════════════════")
    warn("AETHER HUB - Error de conexión:")
    warn(tostring(result))
    warn("Verifica la URL del script")
    warn("═══════════════════════════════════════")
end
