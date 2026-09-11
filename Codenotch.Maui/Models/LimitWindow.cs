using System;

namespace Codenotch.Models;

/// <summary>
/// Represents a window of usage limits.
/// </summary>
public record LimitWindow(
    string Id,
    string Label,
    double? UsedFraction,
    int? Remaining,
    int? Used,
    DateTime? ResetsAt)
{
    public string Summary
    {
        get
        {
            if (UsedFraction.HasValue)
            {
                int usedPercent = (int)Math.Round(UsedFraction.Value * 100);
                return $"{usedPercent}% Used · {100 - usedPercent}% left";
            }
            if (Remaining.HasValue)
            {
                return $"{Remaining.Value} left";
            }
            if (Used.HasValue)
            {
                return $"{Used.Value} used";
            }
            return "No reading";
        }
    }
}
