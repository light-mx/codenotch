# SwiftUI to Flutter UI Mapping Guide

This guide details how SwiftUI concepts, layout rules, and modifiers map directly to Flutter widgets and primitives.

## 1. Core Layout and Containers

| SwiftUI Primitive | Flutter Equivalent | Notes |
|---|---|---|
| `VStack(spacing: s) { ... }` | `Column(spacing: s, children: [...])` | In Flutter, use `Column` with `MainAxisAlignment` and `CrossAxisAlignment`. |
| `HStack(spacing: s) { ... }` | `Row(spacing: s, children: [...])` | Identical horizontal flow. |
| `ZStack { ... }` | `Stack(children: [...])` | Elements stack back-to-front. Use `Positioned` or `Align`. |
| `Spacer(minLength: m)` | `Spacer(flex: 1)` or `SizedBox(width/height: m)` | `Spacer` expands to fill leftover space. |
| `GeometryReader { proxy in ... }` | `LayoutBuilder(builder: (ctx, constraints) => ...)` | `LayoutBuilder` provides available constraints without forcing 10x10 collapse. |
| `ScrollView { ... }` | `SingleChildScrollView(child: ...)` | Vertical or horizontal scroll. |
| `Divider()` | `Divider()` | Thin separation line. |
| `Group { ... }` | Fragment-like list or helper method | Group doesn't introduce layout semantics. |

## 2. Shapes and Custom Drawing

### SwiftUI `Shape`
In SwiftUI:
```swift
struct MyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addArc(...)
        return path
    }
}
```

### Flutter Equivalent
In Flutter, use `CustomPainter` or `CustomClipper<Path>`:
```dart
class MyShapePainter extends CustomPainter {
  final Color color;
  const MyShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path path = Path()
      ..moveTo(rect.left, rect.top)
      ..arcToPoint(...);
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant MyShapePainter oldDelegate) => oldDelegate.color != color;
}
```

## 3. View Modifiers to Widget Composition

| SwiftUI Modifier | Flutter Equivalent | Notes |
|---|---|---|
| `.frame(width: w, height: h)` | `SizedBox(width: w, height: h, child: ...)` | Explicit sizing. |
| `.padding(p)` | `Padding(padding: EdgeInsets.all(p), child: ...)` | Inner spacing. |
| `.background(color)` | `DecoratedBox(decoration: BoxDecoration(color: ...))` | Or `Container(color: ...)`. |
| `.clipShape(shape)` | `ClipPath(clipper: MyClipper(), child: ...)` | Or `ClipRRect(borderRadius: ...)`. |
| `.opacity(val)` | `Opacity(opacity: val, child: ...)` | Transparent rendering. |
| `.offset(x: dx, y: dy)` | `Transform.translate(offset: Offset(dx, dy), child: ...)` | Shift positioning without reflowing layout. |
| `.scaleEffect(s)` | `Transform.scale(scale: s, child: ...)` | Scale transform from center. |
| `.rotationEffect(.degrees(deg))` | `Transform.rotate(angle: deg * pi / 180, child: ...)` | Rotation around origin. |
| `.onHover { inside in ... }` | `MouseRegion(onEnter: ..., onExit: ..., child: ...)` | Native pointer tracking. |
| `.allowsHitTesting(bool)` | `IgnorePointer(ignoring: !bool, child: ...)` | Enable or bypass hit tests. |

## 4. Animations and Transitions

- **Implicit Animations**:
  - SwiftUI `.animation(.spring(...), value: state)` -> Flutter `AnimatedContainer`, `AnimatedOpacity`, `AnimatedSlide`, or custom `TweenAnimationBuilder`.
- **Explicit Animations**:
  - SwiftUI `withAnimation(...) { ... }` -> Flutter `AnimationController` with `CurvedAnimation(parent: ctrl, curve: Curves.easeOut)`.
- **Springs**:
  - SwiftUI `.spring(response: 0.3, dampingFraction: 0.85)` -> Flutter `SpringSimulation(SpringDescription(mass: 1, stiffness: k, damping: c), 0, 1, 0)`.
