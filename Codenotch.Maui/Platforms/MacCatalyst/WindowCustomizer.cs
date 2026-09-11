#if MACCATALYST
using System.Runtime.InteropServices;
using ObjCRuntime;
using UIKit;
using Microsoft.Maui.Controls;

namespace Codenotch.Platforms.MacCatalyst;

/// <summary>
/// Bridges MAUI Mac Catalyst UIWindow to AppKit NSWindow to create
/// a borderless, transparent, non-activating, always-on-top panel
/// matching Codenotch's NotchPanel.swift.
/// </summary>
public static class WindowCustomizer
{
    private const string LibObjC = "/usr/lib/libobjc.dylib";

    [DllImport(LibObjC)]
    private static extern IntPtr objc_getClass(string className);

    [DllImport(LibObjC)]
    private static extern IntPtr sel_registerName(string selector);

    [DllImport(LibObjC)]
    private static extern IntPtr objc_msgSend(IntPtr receiver, IntPtr selector);

    [DllImport(LibObjC)]
    private static extern IntPtr objc_msgSend(IntPtr receiver, IntPtr selector, IntPtr arg);

    [DllImport(LibObjC)]
    private static extern IntPtr objc_msgSend(IntPtr receiver, IntPtr selector, byte arg);

    [DllImport(LibObjC)]
    private static extern IntPtr objc_msgSend(IntPtr receiver, IntPtr selector, long arg);

    [DllImport(LibObjC)]
    private static extern IntPtr objc_msgSend(IntPtr receiver, IntPtr selector, double arg);

    [DllImport(LibObjC)]
    private static extern IntPtr objc_msgSend(IntPtr receiver, IntPtr selector, CGRect arg);

    [StructLayout(LayoutKind.Sequential)]
    public struct CGRect
    {
        public double X;
        public double Y;
        public double Width;
        public double Height;

        public CGRect(double x, double y, double width, double height)
        {
            X = x;
            Y = y;
            Width = width;
            Height = height;
        }
    }

    public static void ConfigureNotchWindow(Window window)
    {
        if (window.Handler?.PlatformView is UIWindow uiWindow)
        {
            ConfigureUIWindow(uiWindow);
        }
    }

    public static void ConfigureUIWindow(UIWindow uiWindow)
    {
        try
        {
            // Make UIWindow transparent
            uiWindow.Opaque = false;
            uiWindow.BackgroundColor = UIColor.Clear;

            // Obtain host NSWindow via delegate
            IntPtr nsApp = objc_msgSend(objc_getClass("NSApplication"), sel_registerName("sharedApplication"));
            IntPtr appDelegate = objc_msgSend(nsApp, sel_registerName("delegate"));
            IntPtr hostWindowSelector = sel_registerName("hostWindowForUIWindow:");

            IntPtr nsWindow = objc_msgSend(appDelegate, hostWindowSelector, uiWindow.Handle);
            if (nsWindow != IntPtr.Zero)
            {
                // 1. StyleMask: Borderless (0)
                objc_msgSend(nsWindow, sel_registerName("setStyleMask:"), (IntPtr)0);

                // 2. Transparency: isOpaque = false, backgroundColor = clearColor, hasShadow = false
                objc_msgSend(nsWindow, sel_registerName("setOpaque:"), (byte)0);
                IntPtr clearColor = objc_msgSend(objc_getClass("NSColor"), sel_registerName("clearColor"));
                objc_msgSend(nsWindow, sel_registerName("setBackgroundColor:"), clearColor);
                objc_msgSend(nsWindow, sel_registerName("setHasShadow:"), (byte)0);

                // 3. Floating window level: statusBar = 25 (floats above menus and full-screen spaces)
                objc_msgSend(nsWindow, sel_registerName("setLevel:"), (IntPtr)25);

                // 4. Collection Behavior: CanJoinAllSpaces (1) | Stationary (16) | FullScreenAuxiliary (256) = 273
                objc_msgSend(nsWindow, sel_registerName("setCollectionBehavior:"), (IntPtr)273);

                // 5. Non-activating behavior
                objc_msgSend(nsWindow, sel_registerName("setHidesOnDeactivate:"), (byte)0);

                // 6. Title visibility
                if (uiWindow.WindowScene?.Titlebar != null)
                {
                    uiWindow.WindowScene.Titlebar.TitleVisibility = UITitlebarTitleVisibility.Hidden;
                    uiWindow.WindowScene.Titlebar.Toolbar = null;
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[Codenotch] WindowCustomizer configuration error: {ex.Message}");
        }
    }

    public static void SetWindowFrame(UIWindow uiWindow, double x, double y, double width, double height)
    {
        try
        {
            IntPtr nsApp = objc_msgSend(objc_getClass("NSApplication"), sel_registerName("sharedApplication"));
            IntPtr appDelegate = objc_msgSend(nsApp, sel_registerName("delegate"));
            IntPtr hostWindowSelector = sel_registerName("hostWindowForUIWindow:");
            IntPtr nsWindow = objc_msgSend(appDelegate, hostWindowSelector, uiWindow.Handle);

            if (nsWindow != IntPtr.Zero)
            {
                var frame = new CGRect(x, y, width, height);
                IntPtr setFrameSel = sel_registerName("setFrame:display:");
                // objc_msgSend for struct on arm64/x64
                objc_msgSend(nsWindow, setFrameSel, frame);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[Codenotch] SetWindowFrame error: {ex.Message}");
        }
    }
}
#endif
