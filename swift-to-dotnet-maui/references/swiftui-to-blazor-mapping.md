# SwiftUI to Blazor Component Mapping

When converting SwiftUI layouts to Blazor Hybrid, we map Swift's declarative UI concepts to HTML/CSS representations in Razor components.

## Layout Containers

| SwiftUI | HTML/CSS Equivalent | Notes |
|---------|--------------------|-------|
| `VStack { }` | `<div class="d-flex flex-column">` | Use flexbox. Gap translates nicely to CSS `gap: 10px;`. |
| `HStack { }` | `<div class="d-flex flex-row">` | Standard row layout. |
| `ZStack { }` | `<div style="position: relative;">` + absolute children | The container needs relative positioning, while children inside need absolute positioning to overlap. |
| `Spacer()` | `<div class="flex-grow-1"></div>` | Flexbox flex-grow forces siblings apart. |
| `ScrollView` | `<div style="overflow-y: auto;">` | Ensure the container has a defined height or `flex: 1`. |

## Basic Components

| SwiftUI | Blazor HTML | Notes |
|---------|-------------|-------|
| `Text("Hello")` | `<span>Hello</span>` | Use `<p>`, `<h1>`-`<h6>`, or `<span>` depending on semantic meaning. |
| `Button(action: { }) { }` | `<button @onclick="Action">` | Use standard HTML buttons styled with CSS. |
| `Image("logo")` | `<img src="images/logo.png" />` | Static assets go in `wwwroot/`. For SF Symbols, consider an icon font like FontAwesome or SVG extraction. |
| `TextField("Hint", text: $text)` | `<input type="text" placeholder="Hint" @bind="text" @bind:event="oninput" />` | Use `@bind:event="oninput"` for immediate updates like SwiftUI. |

## Modifiers Mapping

| SwiftUI Modifier | CSS Equivalent |
|------------------|----------------|
| `.padding()` | `padding: 16px;` |
| `.background(Color.red)` | `background-color: var(--color-red);` |
| `.cornerRadius(8)` | `border-radius: 8px;` |
| `.frame(width: 100, height: 50)` | `width: 100px; height: 50px;` |
| `.opacity(0.5)` | `opacity: 0.5;` |
| `.shadow(radius: 5)` | `box-shadow: 0px 4px 5px rgba(0,0,0,0.2);` |

## Example: Complex Card

**SwiftUI:**
```swift
struct UserCard: View {
    var name: String
    var body: some View {
        HStack {
            Image("avatar")
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                Text("Online").font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
```

**Blazor (.razor):**
```razor
<div class="user-card">
    <img src="images/avatar.png" class="avatar" />
    <div class="user-info">
        <span class="headline">@Name</span>
        <span class="subheadline online">Online</span>
    </div>
    <div class="flex-grow-1"></div>
</div>

<style>
.user-card {
    display: flex;
    flex-direction: row;
    padding: 16px;
    background-color: white;
    border-radius: 10px;
    box-shadow: 0px 4px 5px rgba(0,0,0,0.1);
    align-items: center;
}
.avatar {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    margin-right: 12px;
}
.user-info {
    display: flex;
    flex-direction: column;
}
.headline { font-weight: bold; font-size: 1.1em; }
.subheadline { font-size: 0.9em; color: gray; }
</style>

@code {
    [Parameter] public string Name { get; set; } = "";
}
```
