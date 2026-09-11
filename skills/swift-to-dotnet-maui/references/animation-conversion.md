# Animation Conversion: SwiftUI to CSS

SwiftUI uses a declarative, highly physics-based animation system, primarily built around springs. Blazor uses standard HTML/CSS, so we convert SwiftUI animations into CSS transitions and `@keyframes`.

## Easing Functions

| SwiftUI | CSS Equivalent |
|---------|----------------|
| `.animation(.linear)` | `transition: all 0.3s linear;` |
| `.animation(.easeIn)` | `transition: all 0.3s ease-in;` |
| `.animation(.easeOut)` | `transition: all 0.3s ease-out;` |
| `.animation(.easeInOut)` | `transition: all 0.3s ease-in-out;` |

## Spring Animations

SwiftUI's most common animation is the spring: `.spring(response: 0.5, dampingFraction: 0.8)`. 
CSS doesn't have a native `spring()` function (though `linear()` is arriving in modern CSS, `cubic-bezier` is the standard approach for broad compatibility).

To approximate a spring in CSS, we use custom `cubic-bezier()` functions that emulate the overshoot.

### Common Spring Approximations

1. **Standard Bouncy Spring**
   - SwiftUI: `.spring(response: 0.5, dampingFraction: 0.6)`
   - CSS: `transition: all 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);`

2. **Smooth/Stiff Spring (No bounce)**
   - SwiftUI: `.spring(response: 0.3, dampingFraction: 1.0)`
   - CSS: `transition: all 0.3s cubic-bezier(0.25, 1, 0.5, 1);` (similar to ease-out)

3. **Very Bouncy**
   - SwiftUI: `.spring(response: 0.6, dampingFraction: 0.4)`
   - CSS: `transition: all 0.6s cubic-bezier(0.68, -0.55, 0.26, 1.55);`

## Explicit Animations (`withAnimation`)

In SwiftUI, you trigger animations by mutating state inside `withAnimation`.
In Blazor, you mutate state, which changes a CSS class or inline style. The `transition` property on the element handles the animation automatically.

**SwiftUI:**
```swift
struct BouncyButton: View {
    @State private var isScaled = false
    
    var body: some View {
        Button("Press") {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isScaled.toggle()
            }
        }
        .scaleEffect(isScaled ? 1.5 : 1.0)
    }
}
```

**Blazor / CSS:**
```razor
<button class="bouncy-btn @(isScaled ? "scaled" : "")" @onclick="ToggleScale">
    Press
</button>

<style>
.bouncy-btn {
    transform: scale(1);
    /* Approximate the spring */
    transition: transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.bouncy-btn.scaled {
    transform: scale(1.5);
}
</style>

@code {
    private bool isScaled = false;
    private void ToggleScale() {
        isScaled = !isScaled;
    }
}
```

## Keyframe Animations

For complex sequences, SwiftUI's `.keyframeAnimator` maps cleanly to CSS `@keyframes`.

**SwiftUI:**
*(Requires iOS 17+ / macOS 14+)*
```swift
// A sequence of rotations and scales
```

**CSS:**
```css
@keyframes wobble {
  0% { transform: rotate(0deg); }
  25% { transform: rotate(-5deg); }
  50% { transform: rotate(5deg); }
  75% { transform: rotate(-5deg); }
  100% { transform: rotate(0deg); }
}

.wobble-element {
  animation: wobble 0.5s ease-in-out;
}
```
