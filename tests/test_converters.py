import unittest
from pathlib import Path
import sys

REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO_ROOT))

from tools.color_palette_extractor import parse_colors, format_css, format_dart, format_csharp

class TestConverters(unittest.TestCase):
    def setUp(self):
        self.fixtures_dir = REPO_ROOT / "tests" / "fixtures"

    def test_color_extraction(self):
        palette_file = self.fixtures_dir / "SamplePalette.swift"
        with open(palette_file, "r") as f:
            content = f.read()

        colors = parse_colors(content)
        self.assertIn("primaryBrand", colors)
        self.assertEqual(colors["primaryBrand"]["hex"], "#3B82F6")
        self.assertIn("surfaceDark", colors)
        self.assertEqual(colors["surfaceDark"]["hex"], "#1E1E2E")
        self.assertIn("accentSuccess", colors)

        # Test CSS export
        css = format_css(colors)
        self.assertIn("--color-primary-brand: #3B82F6;", css)

        # Test Dart export
        dart = format_dart(colors)
        self.assertIn("Color(0xFF3B82F6)", dart)

        # Test C# export
        csharp = format_csharp(colors)
        self.assertIn('public const string PrimaryBrand = "#3B82F6";', csharp)

    def test_swift_struct_to_csharp(self):
        sys.path.insert(0, str(REPO_ROOT / "skills" / "swift-to-dotnet-maui" / "scripts"))
        import importlib
        struct_converter = importlib.import_module("convert-swift-struct")

        swift_code = """
        struct SimpleItem {
            let id: UUID
            var name: String
        }
        """
        csharp = struct_converter.convert_swift_struct_to_csharp(swift_code)
        self.assertIn("public record SimpleItem", csharp)
        self.assertIn("public Guid Id { get; init; }", csharp)
        self.assertIn("public string Name { get; set; }", csharp)

    def test_swift_enum_to_csharp(self):
        sys.path.insert(0, str(REPO_ROOT / "skills" / "swift-to-dotnet-maui" / "scripts"))
        import importlib
        enum_converter = importlib.import_module("convert-swift-enum")

        standard_enum = """
        enum Mode: String, CaseIterable {
            case light
            case dark
        }
        """
        csharp_standard = enum_converter.convert_swift_enum_to_csharp(standard_enum)
        self.assertIn("public enum Mode", csharp_standard)
        self.assertIn("Light", csharp_standard)
        self.assertIn("Dark", csharp_standard)

        discriminated_enum = """
        enum Action {
            case click(x: Int, y: Int)
            case close
        }
        """
        csharp_union = enum_converter.convert_swift_enum_to_csharp(discriminated_enum)
        self.assertIn("public abstract record Action", csharp_union)
        self.assertIn("public sealed record Click(int X, int Y) : Action;", csharp_union)
        self.assertIn("public sealed record Close() : Action;", csharp_union)

if __name__ == "__main__":
    unittest.main()
