import unittest
from pathlib import Path
import sys

REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO_ROOT))

from tools.swift_ast_analyzer import analyze_directory, analyze_swift_file

class TestSwiftASTAnalyzer(unittest.TestCase):
    def setUp(self):
        self.fixtures_dir = REPO_ROOT / "tests" / "fixtures"

    def test_sample_views_analysis(self):
        view_file = self.fixtures_dir / "SampleViews.swift"
        stats = analyze_swift_file(view_file)
        
        self.assertIn("SampleDashboardView", stats["views"])
        self.assertIn("SampleBadgeShape", stats["shapes"])
        self.assertIn("NSPanel", stats["appkit"])
        self.assertIn("NSStatusItem", stats["appkit"])
        self.assertTrue(stats["has_state"])

    def test_sample_models_analysis(self):
        models_file = self.fixtures_dir / "SampleModels.swift"
        stats = analyze_swift_file(models_file)
        self.assertEqual(len(stats["views"]), 0)
        self.assertEqual(len(stats["shapes"]), 0)

    def test_directory_scan(self):
        report = analyze_directory(str(self.fixtures_dir))
        self.assertGreaterEqual(report["swift_files_count"], 3)
        self.assertIn("SampleDashboardView", report["swiftui_views"])
        self.assertIn("SampleBadgeShape", report["swiftui_shapes"])
        self.assertIn("NSPanel", report["appkit_dependencies"])

if __name__ == "__main__":
    unittest.main()
