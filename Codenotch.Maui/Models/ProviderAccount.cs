using System;
using System.Linq;

namespace Codenotch.Models;

/// <summary>
/// Represents a user's account with a provider.
/// </summary>
public record ProviderAccount(string? Email, string? PlanName, Uri? ManageUrl)
{
    public string Summary => string.Join(" · ", new[] { Email, PlanName }.Where(x => !string.IsNullOrEmpty(x)));
}

/// <summary>
/// Represents the route used to sign in to a provider.
/// </summary>
public abstract record SignInRoute
{
    private SignInRoute() { }

    public sealed record Modal : SignInRoute;
    public sealed record OpenApp(string BundleId, string Name) : SignInRoute;
    public sealed record Guidance(string Explanation, string? ActionTitle) : SignInRoute;
}

/// <summary>
/// Summarizes provider configuration.
/// </summary>
public record ProviderSummary(
    string Id,
    string Name,
    ProviderGlyph Glyph,
    ProviderAccount? Account,
    SignInRoute SignIn,
    bool WasRefusedAccess);
