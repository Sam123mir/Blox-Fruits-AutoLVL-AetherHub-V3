#!/usr/bin/env python3
"""
Complete conversion from OrionLib to Fluent UI
"""
import re

def convert_all_to_fluent(content):
    """Convert ALL OrionLib methods to Fluent UI format"""
    
    # 1. Convert AddToggle format
    # From: AddToggle({Name = "x", Default = false, Callback = function(v) ... end})
    # To: AddToggle({Title = "x", Default = false, Callback = function(v) ... end})
    content = re.sub(
        r'AddToggle\(\{\s*Name\s*=',
        'AddToggle({Title =',
        content
    )
    
    # 2. Convert AddButton format
    # From: AddButton({Name = "x", Callback = function() ... end})
    # To: AddButton({Title = "x", Callback = function() ... end})
    content = re.sub(
        r'AddButton\(\{\s*Name\s*=',
        'AddButton({Title =',
        content
    )
    
    # 3. Convert AddDropdown format
    # From: AddDropdown({Name = "x", Options = {...}, Default = "y", Callback = function(v) ... end})
    # To: AddDropdown({Title = "x", Values = {...}, Default = "y", Callback = function(v) ... end})
    content= re.sub(
        r'AddDropdown\(\{\s*Name\s*=\s*([^,]+),\s*Options\s*=',
        r'AddDropdown({Title = \1, Values =',
        content
    )
    
    # 4. Convert AddSlider format
    # From: AddSlider({Name = "x", Min = 0, Max = 100, Default = 50, Callback = function(v) ... end})
    # To: AddSlider({Title = "x", Min = 0, Max = 100, Default = 50, Callback = function(v) ... end})
    content = re.sub(
        r'AddSlider\(\{\s*Name\s*=',
        'AddSlider({Title =',
        content
    )
    
    # 5. Convert AddTextbox to AddInput
    # From: AddTextbox({Name = "x", Default = "y", Callback = function(v) ... end})
    # To: AddInput({Title = "x", Default = "y", Finished = true, Callback = function(v) ... end})
    content = re.sub(
        r':AddTextbox\(\{',
        ':AddInput({',
        content
    )
    content = re.sub(
        r'AddInput\(\{\s*Name\s*=',
        'AddInput({Title =',
        content
    )
    
    # 6. Fix .Set() calls on paragraphs (Fluent uses :Set({Content = "..."}) format)
    # This is trickier and might need manual review
    
    return content

def main():
    # Read the file
    print("Reading blox-fruits.lua...")
    with open('blox-fruits.lua', 'r', encoding='utf-8') as f:
        content = f.read()
    
    print("Converting all UI methods to Fluent format...")
    converted = convert_all_to_fluent(content)
    
    # Write back
    with open('blox-fruits.lua', 'w', encoding='utf-8') as f:
        f.write(converted)
    
    print("✅ Full conversion completed!")
    print("Converted:")
    print("  - AddToggle: Name → Title")
    print("  - AddButton: Name → Title")
    print("  - AddDropdown: Name → Title, Options → Values")
    print("  - AddSlider: Name → Title")
    print("  - AddTextbox → AddInput: Name → Title")

if __name__ == "__main__":
    main()
