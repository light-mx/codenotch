using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Codenotch.Models;

namespace Codenotch.Services.Providers;

public class ClaudeOAuthProvider : IUsageProvider
{
    public string Id => "claude";
    public string DisplayName => "Claude";
    public ProviderGlyph Glyph => ProviderGlyph.Claude;
    public SignInRoute SignInRoute => new SignInRoute.Guidance("Sign in via Claude Code in terminal", "Open Terminal");

    private readonly HttpClient? _httpClient;

    public ClaudeOAuthProvider(HttpClient? httpClient = null)
    {
        _httpClient = httpClient;
    }

    public async Task<ProviderSnapshot> FetchSnapshotAsync()
    {
        await Task.CompletedTask;
        return new ProviderSnapshot(
            Id,
            DisplayName,
            Glyph,
            Fidelity.Official,
            new ProviderStatus.Ok(),
            new List<LimitWindow>
            {
                new LimitWindow("session", "Current session", 0.73, null, null, DateTime.UtcNow.AddMinutes(51)),
                new LimitWindow("all_models", "All models", 0.07, null, null, DateTime.UtcNow.AddDays(5))
            },
            "session"
        );
    }

    public ProviderAccount? Account() => new ProviderAccount("user@anthropic.com", "Claude Pro", new Uri("https://claude.ai/settings/usage"));
    public async Task SignOutAsync() => await Task.CompletedTask;
    public void PresentSignIn() { }
    public void ForgetCachedCredential() { }
}
