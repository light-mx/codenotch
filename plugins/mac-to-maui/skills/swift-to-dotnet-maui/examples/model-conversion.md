# Example: Model Conversion

This example demonstrates how to convert a standard Swift `struct` model into a C# `record`. Using C# records provides the same value-equality semantics that Swift structs offer by default.

## Before: Swift `LimitWindow`

```swift
import Foundation

struct LimitWindow: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var maxProcesses: Int
    var isActive: Bool
    let createdAt: Date
    
    // Computed property
    var isStrict: Bool {
        return maxProcesses < 5
    }
    
    init(id: UUID = UUID(), name: String, maxProcesses: Int, isActive: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.maxProcesses = maxProcesses
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
```

## After: C# `LimitWindow`

```csharp
using System;
using System.Text.Json.Serialization;

// C# records automatically provide Equatable semantics and a neat constructor syntax.
public record LimitWindow(
    Guid Id,
    string Name,
    int MaxProcesses,
    bool IsActive,
    DateTime CreatedAt
)
{
    // Computed property
    public bool IsStrict => MaxProcesses < 5;

    // Parameterless constructor for JSON deserialization (if needed) or default values
    public LimitWindow(string name, int maxProcesses) 
        : this(Guid.NewGuid(), name, maxProcesses, true, DateTime.UtcNow)
    {
    }
}
```

### Key Differences Noted:
1. **Immutability:** The C# primary constructor `record` makes all properties `init`-only by default. If `name` needs to be mutable after initialization (like `var name: String`), you would define the record explicitly with `{ get; set; }` properties instead of using the primary constructor syntax.
2. **UUID to Guid:** Swift `UUID` maps directly to C# `Guid`.
3. **Date to DateTime:** Swift `Date` maps to `DateTime` (often `DateTime.UtcNow`).
4. **Codable:** C# records work natively with `System.Text.Json` for serialization, equivalent to Swift's `Codable`.
