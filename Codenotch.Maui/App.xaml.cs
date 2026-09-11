namespace Codenotch;

/// <summary>
/// MAUI application entry point. Creates and configures the main window
/// for the notch overlay. On macOS, the window is made borderless,
/// transparent, and always-on-top via platform-specific code.
/// </summary>
public partial class App : Application
{
    public App()
    {
        InitializeComponent();
    }

    protected override Window CreateWindow(IActivationState? activationState)
    {
        var window = new Window(new MainPage())
        {
            Title = "Codenotch",
        };

        window.HandlerChanged += (s, e) =>
        {
#if MACCATALYST
            Platforms.MacCatalyst.WindowCustomizer.ConfigureNotchWindow(window);
#endif
        };

        return window;
    }
}
