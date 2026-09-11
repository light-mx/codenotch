---
name: swift-to-dotnet-maui
description: Comprehensive guide for converting Swift/SwiftUI macOS applications to .NET MAUI Blazor Hybrid apps. Covers component mapping, animation conversion, platform API bridging, and project structure.
---

# Swift/SwiftUI to .NET MAUI Blazor Hybrid Conversion

## When to use
This skill is tailored for migrating native macOS applications built with Swift and SwiftUI to cross-platform applications using .NET MAUI Blazor Hybrid. Use this guide when:
- Porting an existing macOS app to Windows, iOS, and Android using a single codebase.
- Replicating complex custom UIs and animations using HTML/CSS (Blazor) rather than MAUI XAML.
- Retaining full access to native platform APIs (like AppKit/MacCatalyst on macOS) via .NET interop.

## Architecture Decisions: XAML vs Blazor Hybrid
- **Blazor Hybrid**: Recommended. It hosts web components inside a native WebView. It excels at porting intricate SwiftUI designs because CSS provides granular control over layout (Flexbox/Grid), typography, and animations (springs via cubic-bezier).
- **MAUI XAML**: Best for standard enterprise apps that use native controls. However, trying to pixel-match custom SwiftUI designs using XAML is often more difficult and verbose than using CSS.

## Step-by-Step Conversion Methodology
1. **Domain Models**: Translate Swift `struct`s to C# `record`s, and `enum`s to C# `enum`s (or abstract records/discriminated unions if they have associated values). See [convert-swift-struct.py](./scripts/convert-swift-struct.py).
2. **Reactive State & ViewModels**: Migrate Combine `ObservableObject` and `@Published` properties to C# view models implementing `INotifyPropertyChanged` or utilizing frameworks like ReactiveUI.
3. **UI Layout**: Map SwiftUI components (`VStack`, `HStack`, `ZStack`) to Blazor structural elements (HTML `div`s with Flexbox CSS). See [swiftui-to-blazor-mapping.md](./references/swiftui-to-blazor-mapping.md).
4. **Styling & Animations**: Extract Swift color palettes to CSS custom properties. Translate SwiftUI spring animations to CSS `@keyframes` and transitions. See [animation-conversion.md](./references/animation-conversion.md).
5. **Platform Interop**: Replace direct `AppKit` usage with MAUI Essentials cross-platform APIs, or use MacCatalyst specific P/Invoke patterns for unmapped APIs. See [appkit-to-maui-mapping.md](./references/appkit-to-maui-mapping.md).

## Common Pitfalls
- **State Propagation**: SwiftUI implicitly updates views on `@State` changes. In Blazor, UI updates require `StateHasChanged()` (often handled automatically on DOM events, but manual invocation is needed for background tasks).
- **Binding Syntax**: SwiftUI `@Binding` becomes two-way binding in Blazor (`@bind-Value="property" @bind-Value:event="OnValueChanged"`).
- **Thread Safety**: UI updates in MAUI must happen on the main thread (`MainThread.BeginInvokeOnMainThread()`).

## Quick Reference
- [SwiftUI to Blazor Components](./references/swiftui-to-blazor-mapping.md)
- [AppKit to MAUI APIs](./references/appkit-to-maui-mapping.md)
- [Animation Conversion](./references/animation-conversion.md)
- [Combine to C# Reactive](./references/combine-to-csharp-mapping.md)
