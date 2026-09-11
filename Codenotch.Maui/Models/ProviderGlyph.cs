namespace Codenotch.Models;

/// <summary>
/// Represents the visual glyph for a provider.
/// </summary>
public enum ProviderGlyph
{
    Claude,
    OpenAI,
    Third,
    Cursor,
    Antigravity,
    Glm,
    Grok,
    Opencode
}

public static class ProviderGlyphExtensions
{
    public static double GetOpticalScale(this ProviderGlyph glyph)
    {
        return glyph switch
        {
            ProviderGlyph.Claude => 1.0,
            ProviderGlyph.OpenAI => 1.0,
            ProviderGlyph.Cursor => 1.1,
            ProviderGlyph.Antigravity => 1.1,
            _ => 1.0
        };
    }
    
    public static string GetSvgPath(this ProviderGlyph glyph)
    {
        // Placeholder for SVG paths
        return string.Empty;
    }
}
