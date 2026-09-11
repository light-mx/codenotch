import re
import sys

def convert_colors_to_css(swift_code: str) -> str:
    """
    Parses Swift Color extensions and outputs CSS custom properties.
    Looks for Color(hex: "#RRGGBB") or Color(red: r, green: g, blue: b)
    """
    css_vars = []
    
    # Matches: static let brandPrimary = Color(hex: "#1A2B3C")
    hex_pattern = re.compile(r'(?:static\s+let|var)\s+(\w+)\s*=\s*Color\(hex:\s*"#([A-Fa-f0-9]+)"\)')
    # Matches: static let brandSecondary = Color(red: 0.1, green: 0.2, blue: 0.3)
    rgb_pattern = re.compile(r'(?:static\s+let|var)\s+(\w+)\s*=\s*Color\(red:\s*([\d\.]+),\s*green:\s*([\d\.]+),\s*blue:\s*([\d\.]+)\)')
    
    lines = swift_code.split('\n')
    for line in lines:
        hex_match = hex_pattern.search(line)
        if hex_match:
            name = to_kebab_case(hex_match.group(1))
            hex_val = hex_match.group(2)
            css_vars.append(f"    --color-{name}: #{hex_val};")
            continue
            
        rgb_match = rgb_pattern.search(line)
        if rgb_match:
            name = to_kebab_case(rgb_match.group(1))
            r = int(float(rgb_match.group(2)) * 255)
            g = int(float(rgb_match.group(3)) * 255)
            b = int(float(rgb_match.group(4)) * 255)
            css_vars.append(f"    --color-{name}: rgb({r}, {g}, {b});")
            
    css = ":root {\n"
    css += "\n".join(css_vars)
    css += "\n}\n"
    return css

def to_kebab_case(name: str) -> str:
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1-\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1-\2', s1).lower()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python generate-css-from-palette.py <file.swift>")
        sys.exit(1)
        
    with open(sys.argv[1], 'r') as f:
        print(convert_colors_to_css(f.read()))
