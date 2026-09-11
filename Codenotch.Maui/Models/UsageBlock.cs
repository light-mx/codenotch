using System;

namespace Codenotch.Models;

/// <summary>
/// Represents a block of usage that prevents further requests until a certain time.
/// </summary>
public record UsageBlock(string Reason, DateTime? ResetsAt)
{
    public string Summary(DateTime? now = null)
    {
        var currentTime = now ?? DateTime.Now;
        if (ResetsAt.HasValue && ResetsAt.Value > currentTime)
        {
            var resetsAt = ResetsAt.Value;
            string timeFormat = resetsAt.Date == currentTime.Date ? "h:mm tt" : "ddd h:mm tt";
            return $"{Reason} until {resetsAt.ToString(timeFormat)}";
        }
        return string.Empty;
    }
}
