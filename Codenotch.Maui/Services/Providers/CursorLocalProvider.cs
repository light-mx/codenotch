using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Codenotch.Models;

namespace Codenotch.Services.Providers;

public class CursorLocalProvider : IUsageProvider
{
    public string Id => "cursor";
    public string DisplayName => "Cursor";
    public ProviderGlyph Glyph => ProviderGlyph.Cursor;
    public SignInRoute SignInRoute => new SignInRoute.OpenApp("com.todesktop.230313mzl4w4u92", "Cursor");

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
                new LimitWindow("included", "Fast Requests", 0.21, 395, 105, DateTime.UtcNow.AddDays(12))
            },
            "included"
        );
    }

    public ProviderAccount? Account() => new ProviderAccount("user@cursor.sh", "Pro", new Uri("https://cursor.com/settings"));
    public async Task SignOutAsync() => await Task.CompletedTask;
    public void PresentSignIn() { }
    public void ForgetCachedCredential() { }
}
