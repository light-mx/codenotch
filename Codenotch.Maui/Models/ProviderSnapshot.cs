using System.Collections.Generic;
using System.Linq;

namespace Codenotch.Models;

/// <summary>
/// Represents a snapshot of a provider's state.
/// </summary>
public record ProviderSnapshot(
    string Id,
    string DisplayName,
    ProviderGlyph Glyph,
    Fidelity Fidelity,
    ProviderStatus Status,
    IReadOnlyList<LimitWindow> Windows,
    string? HeadlineID = null,
    UsageBlock? Block = null)
{
    public LimitWindow? Headline => Windows.FirstOrDefault(w => w.Id == HeadlineID) ?? Windows.FirstOrDefault();
    
    public double? UsedFraction => Headline?.UsedFraction;
    public double? AggregateUsedFraction => UsedFraction;
    
    public string HeadlineText => Headline?.Summary ?? "No reading";
    
    public bool HasReading => Windows.Count > 0;
    
    public double? RingFraction => UsedFraction;

    public bool IsStale => Status is ProviderStatus.Stale;
    public bool IsBlocked => Block != null;
    public bool IsRefreshing { get; init; } = false;
    
    public string? StatusMessage => Status switch
    {
        ProviderStatus.Stale stale => $"Stale since {stale.Since:h:mm tt}",
        ProviderStatus.NeedsAuth => "Needs Authentication",
        ProviderStatus.AccessDenied => "Access Denied",
        ProviderStatus.Unsupported u => $"Unsupported: {u.Reason}",
        ProviderStatus.Error e => $"Error: {e.Message}",
        _ => null
    };
}
