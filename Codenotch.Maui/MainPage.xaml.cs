namespace Codenotch;

public partial class MainPage : ContentPage
{
    public MainPage()
    {
        InitializeComponent();

#if MACCATALYST
        // Make the BlazorWebView transparent so the notch shape renders
        // against a clear background, allowing click-through on empty areas.
        blazorWebView.HandlerChanged += (s, e) =>
        {
            if (blazorWebView.Handler?.PlatformView is UIKit.UIView platformView)
            {
                platformView.Opaque = false;
                platformView.BackgroundColor = UIKit.UIColor.Clear;

                // Walk the view tree to find WKWebView and make it transparent too
                MakeWebViewTransparent(platformView);
            }
        };
#endif
    }

#if MACCATALYST
    private static void MakeWebViewTransparent(UIKit.UIView view)
    {
        if (view is WebKit.WKWebView webView)
        {
            webView.Opaque = false;
            webView.BackgroundColor = UIKit.UIColor.Clear;
            webView.ScrollView.BackgroundColor = UIKit.UIColor.Clear;
            return;
        }

        foreach (var subview in view.Subviews)
        {
            MakeWebViewTransparent(subview);
        }
    }
#endif
}
