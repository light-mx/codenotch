using Microsoft.Extensions.Logging;
using Codenotch.Services;

namespace Codenotch;

public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>();

        builder.Services.AddMauiBlazorWebView();

#if DEBUG
        builder.Services.AddBlazorWebViewDeveloperTools();
#endif

        // Register core services
        builder.Services.AddSingleton<NotchViewModel>();
        builder.Services.AddSingleton<Codenotch.Services.IPreferences, AppPreferences>();
        builder.Services.AddSingleton<UsageArchive>();
        builder.Services.AddSingleton<UsageStore>();

        return builder.Build();
    }
}
