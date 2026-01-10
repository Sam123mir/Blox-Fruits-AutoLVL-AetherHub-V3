#!/usr/bin/env python3
"""
Script to convert OrionLib UI methods to Fluent UI methods
"""
import re

def convert_to_fluent(content):
    """Convert OrionLib syntax to Fluent UI syntax"""
    
    # Convert AddLabel to AddParagraph
    # Pattern: tab:AddLabel("text") or tab:AddLabel('text')
    content = re.sub(
        r'(\w+):AddLabel\((["\'])(.+?)\2\)',
        lambda m: f'{m.group(1)}:AddParagraph({{Title = "", Content = {m.group(2)}{m.group(3)}{m.group(2)}}})',
        content
    )
    
    # Convert variable assignments with AddLabel
    # Pattern: local var = tab:AddLabel("text")
    content = re.sub(
        r'(local\s+\w+\s*=\s*)(\w+):AddLabel\((["\'])(.+?)\3\)',
        lambda m: f'{m.group(1)}{m.group(2)}:AddParagraph({{Title = "", Content = {m.group(3)}{m.group(4)}{m.group(3)}}})',
        content
    )
    
    return content

def main():
    # Read the file
    with open('blox-fruits.lua', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Convert
    converted = convert_to_fluent(content)
    
    # Write back
    with open('blox-fruits.lua', 'w', encoding='utf-8') as f:
        f.write(converted)
    
    print("✅ Conversion completed!")
    print("Converted AddLabel calls to AddParagraph")

if __name__ == "__main__":
    main()
