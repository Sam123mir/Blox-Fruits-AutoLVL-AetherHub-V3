--[[
    AETHER HUB - Debug Test
    Tests module loading and basic functionality
]]

print("================================================")
print("         AETHER HUB - DEBUG TEST v2.0")
print("================================================")

-- Test 1: Load main script
print("\n[TEST 1] Loading main script...")
local success, error = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Blox-Fruits-AutoLVL-AetherHub-V3/main/main.lua"))()
end)

if success then
    print("[TEST 1] OK - Main script loaded successfully!")
else
    print("[TEST 1] ERROR - " .. tostring(error))
end

print("\n================================================")
print("              DEBUG TEST COMPLETE")
print("================================================")
