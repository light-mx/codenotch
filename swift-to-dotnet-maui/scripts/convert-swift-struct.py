import re
import sys

def convert_swift_struct_to_csharp(swift_code: str) -> str:
    # Match struct name and protocols
    struct_match = re.search(r'struct\s+(\w+)(.*?)\s*\{', swift_code)
    if not struct_match:
        return "// Could not parse struct"
        
    struct_name = struct_match.group(1)
    
    # Extract properties (let or var)
    properties = re.findall(r'(let|var)\s+(\w+)\s*:\s*([A-Za-z0-9_\[\]\?\<\>]+)', swift_code)
    
    csharp = f"public record {struct_name}\n{{\n"
    
    for modifier, name, type_name in properties:
        pascal_name = name[0].upper() + name[1:]
        csharp_type = map_type(type_name)
        
        # let -> init-only setter, var -> public setter
        setter = "init" if modifier == "let" else "set"
        
        csharp += f"    public {csharp_type} {pascal_name} {{ get; {setter}; }}\n"
        
    csharp += "}\n"
    return csharp

def map_type(swift_type: str) -> str:
    # Basic mapping
    mapping = {
        'String': 'string', 'Int': 'int', 'Double': 'double', 
        'Float': 'float', 'Bool': 'bool', 'Date': 'DateTime',
        'UUID': 'Guid', 'URL': 'Uri'
    }
    
    # Optional handling
    if swift_type.endswith('?'):
        base = swift_type[:-1]
        return mapping.get(base, base) + '?'
        
    # Array handling
    if swift_type.startswith('[') and swift_type.endswith(']'):
        base = swift_type[1:-1]
        return f"List<{mapping.get(base, base)}>"
        
    return mapping.get(swift_type, swift_type)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python convert-swift-struct.py <file.swift>")
        sys.exit(1)
        
    with open(sys.argv[1], 'r') as f:
        print(convert_swift_struct_to_csharp(f.read()))
