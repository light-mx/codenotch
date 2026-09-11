import re
import sys

def extract_svg_path(swift_code: str) -> str:
    """
    Parses a SwiftUI Path builder block and extracts an SVG path string.
    Supports move(to:), addLine(to:), addArc(), addCurve(), closeSubpath().
    """
    svg_commands = []
    
    # Regex patterns for different path commands
    move_pattern = re.compile(r'move\(to:\s*CGPoint\(x:\s*([\d\.-]+),\s*y:\s*([\d\.-]+)\)\)')
    line_pattern = re.compile(r'addLine\(to:\s*CGPoint\(x:\s*([\d\.-]+),\s*y:\s*([\d\.-]+)\)\)')
    curve_pattern = re.compile(r'addCurve\(to:\s*CGPoint\(x:\s*([\d\.-]+),\s*y:\s*([\d\.-]+)\),\s*control1:\s*CGPoint\(x:\s*([\d\.-]+),\s*y:\s*([\d\.-]+)\),\s*control2:\s*CGPoint\(x:\s*([\d\.-]+),\s*y:\s*([\d\.-]+)\)\)')
    close_pattern = re.compile(r'closeSubpath\(\)')
    
    lines = swift_code.split('\n')
    for line in lines:
        move_match = move_pattern.search(line)
        if move_match:
            svg_commands.append(f"M {move_match.group(1)} {move_match.group(2)}")
            continue
            
        line_match = line_pattern.search(line)
        if line_match:
            svg_commands.append(f"L {line_match.group(1)} {line_match.group(2)}")
            continue
            
        curve_match = curve_pattern.search(line)
        if curve_match:
            # SVG C command: C x1 y1, x2 y2, x y
            svg_commands.append(f"C {curve_match.group(3)} {curve_match.group(4)}, {curve_match.group(5)} {curve_match.group(6)}, {curve_match.group(1)} {curve_match.group(2)}")
            continue
            
        if close_pattern.search(line):
            svg_commands.append("Z")
            
    return " ".join(svg_commands)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python extract-svg-paths.py <file.swift>")
        sys.exit(1)
        
    with open(sys.argv[1], 'r') as f:
        print(extract_svg_path(f.read()))
