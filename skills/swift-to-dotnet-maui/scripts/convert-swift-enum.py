import re
import sys

def convert_swift_enum_to_csharp(swift_code: str) -> str:
    """
    Converts a Swift enum definition to a C# enum or record base class (for associated values).
    """
    lines = swift_code.split('\n')
    
    enum_name_match = re.search(r'enum\s+(\w+)(.*?)\s*\{', swift_code)
    if not enum_name_match:
        return "// Could not parse enum name"
    
    enum_name = enum_name_match.group(1)
    protocols = enum_name_match.group(2).replace(':', '').strip().split(',')
    protocols = [p.strip() for p in protocols if p.strip()]
    
    # Check if we have associated values
    has_associated_values = bool(re.search(r'case\s+\w+\s*\(', swift_code))
    
    if has_associated_values:
        return generate_discriminated_union(enum_name, swift_code)
    else:
        return generate_standard_enum(enum_name, swift_code, protocols)

def generate_standard_enum(name: str, code: str, protocols: list) -> str:
    cases = re.findall(r'case\s+(\w+)(?:\s*=\s*(.+))?', code)
    
    csharp = f"public enum {name}\n{{\n"
    for case_name, raw_value in cases:
        pascal_case = case_name[0].upper() + case_name[1:]
        csharp += f"    {pascal_case}"
        if raw_value:
            csharp += f" = {raw_value.strip()}"
        csharp += ",\n"
    csharp += "}\n"
    
    # Generate extension methods for computed properties or CaseIterable
    if 'CaseIterable' in protocols:
        csharp += f"\npublic static class {name}Extensions\n{{\n"
        csharp += f"    public static {name}[] AllCases => ({name}[])Enum.GetValues(typeof({name}));\n"
        csharp += "}\n"
        
    return csharp

def generate_discriminated_union(name: str, code: str) -> str:
    # C# doesn't have native enums with associated values. We use abstract records.
    cases = re.findall(r'case\s+(\w+)(?:\s*\((.*?)\))?', code)
    
    csharp = f"public abstract record {name}\n{{\n"
    csharp += f"    private {name}() {{ }}\n\n"
    
    for case_name, associated_types in cases:
        pascal_case = case_name[0].upper() + case_name[1:]
        if associated_types:
            props = associated_types.split(',')
            csharp_props = []
            for i, prop in enumerate(props):
                prop = prop.strip()
                if ':' in prop:
                    p_name, p_type = prop.split(':')
                    p_name = p_name.strip()
                    p_name = p_name[0].upper() + p_name[1:]
                    p_type = map_type(p_type.strip())
                    csharp_props.append(f"{p_type} {p_name}")
                else:
                    p_type = map_type(prop)
                    csharp_props.append(f"{p_type} Value{i}")
            
            csharp += f"    public sealed record {pascal_case}({', '.join(csharp_props)}) : {name};\n"
        else:
            csharp += f"    public sealed record {pascal_case}() : {name};\n"
            
    csharp += "}\n"
    return csharp

def map_type(swift_type: str) -> str:
    mapping = {
        'String': 'string', 'Int': 'int', 'Double': 'double', 'Float': 'float',
        'Bool': 'bool', 'Date': 'DateTime'
    }
    return mapping.get(swift_type, swift_type)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python convert-swift-enum.py <file.swift>")
        sys.exit(1)
        
    with open(sys.argv[1], 'r') as f:
        print(convert_swift_enum_to_csharp(f.read()))
