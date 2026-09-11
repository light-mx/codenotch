namespace Codenotch.Models;

/// <summary>
/// Represents the usage band category.
/// </summary>
public enum UsageBand
{
    Ample,
    Watch,
    Critical,
    Exhausted
}

public static class UsageBandExtensions
{
    public static UsageBand GetBand(double usedFraction)
    {
        return usedFraction switch
        {
            < 0.50 => UsageBand.Ample,
            < 0.70 => UsageBand.Watch,
            < 1.00 => UsageBand.Critical,
            _ => UsageBand.Exhausted
        };
    }

    public static string GetColorHex(this UsageBand band)
    {
        return band switch
        {
            UsageBand.Ample => "#00FF88",
            UsageBand.Watch => "#F2FF00",
            UsageBand.Critical => "#FF3F00",
            UsageBand.Exhausted => "#FF3F00",
            _ => "#FFFFFF"
        };
    }
}
