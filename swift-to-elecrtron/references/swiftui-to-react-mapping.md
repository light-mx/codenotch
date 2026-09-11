# SwiftUI to React & Tailwind Mapping Reference

A comprehensive translation guide from SwiftUI declarative paradigms to React 19, TypeScript, and modern CSS/SVG.

---

## 1. Views and Layout Containers

| SwiftUI Concept | React / HTML / Tailwind Equivalent |
|:---|:---|
| `VStack(spacing: X) { ... }` | `<div className="flex flex-col gap-[Xpx]">{children}</div>` |
| `HStack(spacing: X) { ... }` | `<div className="flex flex-row items-center gap-[Xpx]">{children}</div>` |
| `ZStack(alignment: .topLeading) { ... }` | `<div className="relative">{children (absolute positioning)}</div>` |
| `Spacer()` | `<div className="flex-1" />` or `justify-between` on parent |
| `Divider()` | `<hr className="border-t border-[#303030] my-2" />` |
| `GeometryReader { proxy in ... }` | `useRef()` + `ResizeObserver` or CSS container queries / percentage layout |
| `ScrollView { ... }` | `<div className="overflow-y-auto">{children}</div>` |

---

## 2. State & Reactivity

| SwiftUI Pattern | React Pattern | Notes |
|:---|:---|:---|
| `@State private var isHovered: Bool = false` | `const [isHovered, setIsHovered] = useState(false)` | Local component state. |
| `@Binding var value: T` | Props: `{ value: T, onChange: (val: T) => void }` | Two-way data binding. |
| `@ObservedObject var model: ViewModel` | `useSyncExternalStore` or standard React Context / Zustand / Custom Hook | Observable state subscription. |
| `@Environment(\.accessibilityReduceMotion)` | `window.matchMedia('(prefers-reduced-motion: reduce)')` | System accessibility query. |
| `.onChange(of: value) { _, newValue in ... }` | `useEffect(() => { ... }, [value])` | Reactive side effects. |

---

## 3. Shapes, Paths, and Canvas

| SwiftUI | React / SVG Equivalent |
|:---|:---|
| `Circle().strokeBorder(color, lineWidth: W)` | `<circle r={R} stroke={color} strokeWidth={W} fill="none" />` |
| `Circle().trim(from: 0, to: fraction).stroke(...)` | SVG `<circle>` with `strokeDasharray` and `strokeDashoffset` |
| `Capsule().fill(color)` | `<div className="rounded-full" style={{ backgroundColor: color }} />` |
| Custom `Shape` with `path(in rect: CGRect) -> Path` | `<svg><path d="..." fill="..." /></svg>` |
| `.clipShape(...)` | CSS `clip-path: path('...')` or SVG `<clipPath id="...">` |

---

## 4. Circular Progress Arc Calculation

In SwiftUI:
```swift
Circle()
    .trim(from: 0, to: sweep)
    .stroke(band.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
    .rotationEffect(.degrees(-90))
```

In React (SVG):
```tsx
const radius = (diameter - strokeWidth) / 2;
const circumference = 2 * Math.PI * radius;
const strokeDashoffset = circumference * (1 - sweep);

return (
  <svg width={diameter} height={diameter} className="rotate-[-90deg]">
    <circle
      cx={diameter / 2}
      cy={diameter / 2}
      r={radius}
      stroke="#303030"
      strokeWidth={strokeWidth}
      fill="none"
    />
    <circle
      cx={diameter / 2}
      cy={diameter / 2}
      r={radius}
      stroke={color}
      strokeWidth={strokeWidth}
      strokeDasharray={circumference}
      strokeDashoffset={strokeDashoffset}
      strokeLinecap="round"
      fill="none"
      style={{ transition: 'stroke-dashoffset 0.35s ease, stroke 0.35s ease' }}
    />
  </svg>
);
```

---

## 5. Animation Curves

SwiftUI's standard interactive springs:
- `.spring(response: 0.36, dampingFraction: 0.7)` -> CSS `transition: all 360ms cubic-bezier(0.34, 1.56, 0.64, 1)`
- Timing curve `.timingCurve(0.32, 0, 0.14, 1, duration: 0.95)` -> CSS `cubic-bezier(0.32, 0, 0.14, 1)`
