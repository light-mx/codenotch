# AppKit to .NET MAUI Mapping

When porting a macOS app, you often need to translate direct `AppKit` API calls. MAUI Essentials provides cross-platform abstractions for many basics, but MacCatalyst (which powers MAUI on macOS) allows direct access to native APIs via `UIKit` or `AppKit` through bridging.

## UI Elements

| AppKit API | .NET MAUI / MacCatalyst Equivalent |
|------------|-----------------------------------|
| `NSWindow` / `NSPanel` | `Microsoft.Maui.Controls.Window`. To access the native underlying window in MacCatalyst: `window.Handler.PlatformView as UIWindow`. |
| `NSStatusBar` (Menu Bar App) | Not natively supported in MAUI cross-platform. Requires MacCatalyst specific implementation using `Foundation.NSObject` and Objective-C runtime P/Invoke, or relying on community packages. |
| `NSMenu` | MAUI `MenuBarItem` / `MenuFlyoutItem`. |
| `NSScreen` | `DeviceDisplay.MainDisplayInfo`. |
| `NSCursor` | MAUI `PointerGestureRecognizer` can change cursor on hover using `PointerGestureRecognizer.PointerEntered`. |
| `NSPasteboard` | `Microsoft.Maui.ApplicationModel.DataTransfer.Clipboard`. |
| `NSWorkspace.shared.open()` | `Microsoft.Maui.ApplicationModel.Launcher.OpenAsync()`. |

## Key System Services

| AppKit / Foundation API | .NET MAUI Equivalent |
|-------------------------|----------------------|
| `UserDefaults.standard` | `Microsoft.Maui.Storage.Preferences`. |
| `Keychain` | `Microsoft.Maui.Storage.SecureStorage`. |
| `FileManager.default` | `System.IO.Path.AppDataDirectory` / `System.IO.File`. |
| `NotificationCenter` | Local notifications require a plugin like `Plugin.LocalNotification`. Intra-app events map to C# `event` or `WeakReferenceMessenger`. |

## Accessing MacCatalyst Native APIs (P/Invoke & Interop)

Often, MAUI lacks an abstraction for a specific macOS feature (e.g., getting the idle time, or interacting with IOkit). You can use P/Invoke.

### Example: Getting System Idle Time
**Swift:**
```swift
import IOKit
func systemIdleTime() -> Double {
    var iterator: io_iterator_t = 0
    if IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOHIDSystem"), &iterator) == KERN_SUCCESS {
        let entry = IOIteratorNext(iterator)
        if entry != 0 {
            var unmanagedDict: Unmanaged<CFMutableDictionary>? = nil
            if IORegistryEntryCreateCFProperties(entry, &unmanagedDict, kCFAllocatorDefault, 0) == KERN_SUCCESS {
                if let dict = unmanagedDict?.takeRetainedValue() as? [String: Any],
                   let idleTime = dict["HIDIdleTime"] as? UInt64 {
                    return Double(idleTime) / 1_000_000_000.0
                }
            }
        }
    }
    return 0
}
```

**C# (MacCatalyst Specific using P/Invoke):**
```csharp
#if MACCATALYST
using System.Runtime.InteropServices;
using CoreFoundation;

public static class IdleTimeHelper
{
    [DllImport("/System/Library/Frameworks/IOKit.framework/IOKit")]
    private static extern uint IOServiceGetMatchingServices(uint masterPort, IntPtr matching, out uint iterator);

    [DllImport("/System/Library/Frameworks/IOKit.framework/IOKit")]
    private static extern IntPtr IOServiceMatching(string name);
    
    // ... Implement full P/Invoke wrapper for IOKit properties
    // Or use Objective-C runtime methods to bridge.
}
#endif
```

## Platform-Specific Code Organization

In MAUI, place macOS specific implementations in the `Platforms/MacCatalyst` folder.

```csharp
// Define an interface in the shared project
public interface IStatusBarManager {
    void ShowStatusBarItem();
}

// In Platforms/MacCatalyst/StatusBarManager.cs
public class MacStatusBarManager : IStatusBarManager {
    public void ShowStatusBarItem() {
        // MacCatalyst specific UIKit/AppKit implementation
    }
}
```
