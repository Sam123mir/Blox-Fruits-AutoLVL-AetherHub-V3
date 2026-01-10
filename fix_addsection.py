#!/usr/bin/env python3
"""
Script to fix AddSection format for Fluent UI
"""
import re

def fix_add_section(content):
    """Convert AddSection({Name = "text"}) to AddSection("text")"""
    
    # Pattern: AddSection({Name = "text"}) or AddSection({Name = 'text'})
    # or AddSection({ Name = "text" })
    pattern = r':AddSection\(\s*\{\s*Name\s*=\s*(["\'])(.+?)\1\s*\}\s*\)'
    replacement = r':AddSection(\1\2\1)'
    
    content = re.sub(pattern, replacement, content)
    
    return content

def main():
    # Read the file
    with open('blox-fruits.lua', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix AddSection calls
    fixed = fix_add_section(content)
    
    # Write back
    with open('blox-fruits.lua', 'w', encoding='utf-8') as f:
        f.write(fixed)
    
    print("✅ AddSection format fixed!")

if __name__ == "__main__":
    main()
