using System;

namespace Codenotch.Models;

/// <summary>
/// Helper for formatting time until a limit resets.
/// </summary>
public static class ResetCopy
{
    public static string Format(DateTime resetsAt, DateTime? now = null)
    {
        var currentTime = now ?? DateTime.Now;
        var diff = resetsAt - currentTime;
        
        if (diff.TotalMinutes < 60) return $"Resets in {(int)diff.TotalMinutes} min";
        if (diff.TotalDays < 7) return $"Resets {resetsAt.ToString("ddd h:mm tt")}";
        return $"Resets {resetsAt.ToString("MMM d")}";
    }
}
