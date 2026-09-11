# Example: Component Conversion

This example demonstrates how to convert a SwiftUI view into a Blazor Razor component, translating the layout, state, and styling.

## Before: Swift `CounterView.swift`

```swift
import SwiftUI

struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(count)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                Button(action: {
                    count -= 1
                }) {
                    Text("Decrement")
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    count += 1
                }) {
                    Text("Increment")
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}
```

## After: Blazor `CounterView.razor`

```razor
<div class="counter-card">
    <h1 class="count-display">Count: @count</h1>
    
    <div class="button-row">
        <button class="btn btn-decrement" @onclick="Decrement">Decrement</button>
        <button class="btn btn-increment" @onclick="Increment">Increment</button>
    </div>
</div>

<style>
    /* Card Container */
    .counter-card {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 20px; /* Equivalent to VStack spacing */
        padding: 32px;
        background-color: white;
        border-radius: 16px;
        box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1); /* Approximate shadow radius 10 */
        width: fit-content;
    }

    /* Text */
    .count-display {
        font-size: 2rem; /* largeTitle */
        font-weight: bold;
        margin: 0;
    }

    /* Button Row */
    .button-row {
        display: flex;
        flex-direction: row;
        gap: 16px; /* Equivalent to HStack spacing */
    }

    /* Base Button Style */
    .btn {
        padding: 12px 16px;
        border: none;
        border-radius: 8px;
        font-size: 1rem;
        cursor: pointer;
        transition: background-color 0.2s;
    }

    /* Specific Button Styles */
    .btn-decrement {
        background-color: rgba(255, 0, 0, 0.2);
        color: #d00;
    }
    
    .btn-increment {
        background-color: rgba(0, 0, 255, 0.2);
        color: #00d;
    }

    /* Hover effects (optional, but good for web/hybrid) */
    .btn-decrement:hover { background-color: rgba(255, 0, 0, 0.3); }
    .btn-increment:hover { background-color: rgba(0, 0, 255, 0.3); }
</style>

@code {
    private int count = 0;

    private void Increment()
    {
        count++;
    }

    private void Decrement()
    {
        count--;
    }
}
```

### Key Translations:
- **`VStack` & `HStack`** → `display: flex` with `flex-direction: column` or `row`. The `spacing` maps directly to CSS `gap`.
- **Modifiers (.padding, .background, .cornerRadius)** → Standard CSS properties applied to classes.
- **`@State`** → Standard private fields in the `@code` block. Blazor automatically triggers a re-render when DOM events (like `@onclick`) fire.
- **Button Actions** → `@onclick` handlers bound to C# methods.
