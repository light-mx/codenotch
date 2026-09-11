# Combine to C# Reactive Mapping

Swift's Combine framework is used heavily in SwiftUI via `ObservableObject` and `@Published` to propagate state changes. In .NET, the standard approach is `INotifyPropertyChanged` (INPC), though Reactive Extensions (Rx.NET) provides a closer semantic match to Combine streams.

## Standard State Management Mapping

| Combine / SwiftUI | .NET / Blazor | Notes |
|-------------------|---------------|-------|
| `class Model: ObservableObject` | `class Model : INotifyPropertyChanged` | The foundational protocol for state emission. |
| `@Published var name: String` | Full property with `PropertyChanged?.Invoke()` | You must manually invoke the event in the setter. Libraries like CommunityToolkit.Mvvm auto-generate this. |
| `@StateObject` / `@ObservedObject` | Dependency Injection (`@inject`) or Cascading Parameters | In Blazor, inject singleton/scoped ViewModels. |
| `objectWillChange.send()` | `PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(null))` | Triggers a re-render. |

### Boilerplate Example

**Swift:**
```swift
class UserViewModel: ObservableObject {
    @Published var username: String = ""
}
```

**C# (with CommunityToolkit.Mvvm):**
```csharp
using CommunityToolkit.Mvvm.ComponentModel;

public partial class UserViewModel : ObservableObject // Provided by the toolkit
{
    [ObservableProperty]
    private string username = "";
}
```
*Note: The CommunityToolkit auto-generates the public `Username` property and the `INotifyPropertyChanged` invocation.*

## Reactive Streams (Combine to Rx.NET)

If your Swift code uses complex Combine operators (`map`, `filter`, `debounce`, `sink`), map these to System.Reactive (Rx.NET).

| Combine Concept | Rx.NET Equivalent |
|-----------------|-------------------|
| `Publisher` | `IObservable<T>` |
| `Subscriber` | `IObserver<T>` |
| `PassthroughSubject` | `Subject<T>` |
| `CurrentValueSubject` | `BehaviorSubject<T>` |
| `AnyCancellable` | `IDisposable` |
| `.sink(receiveValue:)` | `.Subscribe(value => { })` |
| `.store(in: &cancellables)` | `CompositeDisposable.Add()` |

### Complex Pipeline Example

**Swift (Combine):**
```swift
import Combine

class SearchViewModel {
    @Published var searchQuery = ""
    var results: [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .filter { $0.count > 2 }
            .sink { [weak self] query in
                self?.performSearch(query)
            }
            .store(in: &cancellables)
    }
    
    func performSearch(_ query: String) { /* ... */ }
}
```

**C# (Rx.NET):**
```csharp
using System;
using System.Reactive.Linq;
using System.Reactive.Subjects;
using System.Reactive.Disposables;

public class SearchViewModel : IDisposable
{
    private readonly BehaviorSubject<string> _searchQuery = new BehaviorSubject<string>("");
    private readonly CompositeDisposable _disposables = new CompositeDisposable();
    
    public string SearchQuery 
    {
        get => _searchQuery.Value;
        set => _searchQuery.OnNext(value);
    }
    
    public SearchViewModel()
    {
        _searchQuery
            .Throttle(TimeSpan.FromMilliseconds(300)) // Equivalent to debounce
            .Where(query => query.Length > 2)
            .ObserveOn(System.Threading.SynchronizationContext.Current) // RunLoop.main
            .Subscribe(query => PerformSearch(query))
            .DisposeWith(_disposables); // Extension method for CompositeDisposable
    }
    
    private void PerformSearch(string query) { /* ... */ }
    
    public void Dispose() => _disposables.Dispose();
}
```
