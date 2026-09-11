using System;

namespace Codenotch.Models;

/// <summary>
/// Helper for formatting elapsed time.
/// </summary>
public static class ElapsedCopy
{
    public static string Format(TimeSpan elapsed)
    {
        if (elapsed.TotalSeconds < 45) return "just now";
        if (elapsed.TotalMinutes < 60) return $"{(int)elapsed.TotalMinutes} min";
        return $"{(int)elapsed.TotalHours} hr {elapsed.Minutes} min";
    }
}
