using System;

namespace Codenotch.Models;

/// <summary>
/// Represents the status of a provider reading.
/// </summary>
public abstract record ProviderStatus
{
    private ProviderStatus() { }

    public sealed record Ok : ProviderStatus;
    public sealed record Stale(DateTime Since) : ProviderStatus;
    public sealed record NeedsAuth : ProviderStatus;
    public sealed record AccessDenied : ProviderStatus;
    public sealed record Unsupported(string Reason) : ProviderStatus;
    public sealed record Error(string Message) : ProviderStatus;

    public bool IsStale => this is Stale;
    public DateTime? StaleSince => this is Stale stale ? stale.Since : null;
}
