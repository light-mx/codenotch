# Example: Enum Conversion

This example demonstrates how to convert a Swift enum with associated values into a C# discriminated union pattern using abstract records.

## Before: Swift `UsageBand`

```swift
enum UsageBand: Equatable {
    case low
    case medium
    case high
    case custom(threshold: Double, label: String)
    
    var description: String {
        switch self {
        case .low: return "Low Usage"
        case .medium: return "Medium Usage"
        case .high: return "High Usage"
        case .custom(_, let label): return label
        }
    }
}
```

## After: C# `UsageBand`

Because C# enums cannot hold associated values (`custom(threshold: Double, label: String)`), we use an abstract `record` with sealed nested `record`s.

```csharp
public abstract record UsageBand
{
    // Prevent external inheritance
    private UsageBand() { }

    public sealed record Low() : UsageBand;
    public sealed record Medium() : UsageBand;
    public sealed record High() : UsageBand;
    public sealed record Custom(double Threshold, string Label) : UsageBand;

    // Pattern matching replaces the Swift `switch`
    public string Description => this switch
    {
        Low => "Low Usage",
        Medium => "Medium Usage",
        High => "High Usage",
        Custom custom => custom.Label,
        _ => throw new NotImplementedException()
    };
}
```

### Usage Comparison

**Swift:**
```swift
let band = UsageBand.custom(threshold: 85.0, label: "Critical")
print(band.description) // "Critical"
```

**C#:**
```csharp
UsageBand band = new UsageBand.Custom(85.0, "Critical");
Console.WriteLine(band.Description); // "Critical"
```
