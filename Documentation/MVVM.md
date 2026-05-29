# MVVM

## ViewModel Protocol

**File:** `MVVM/ViewModel.swift`

```swift
public protocol ViewModel: ObservableObject { }
```

`ViewModel` is a marker protocol that refines `ObservableObject`. Conforming types are guaranteed to be classes (the `ObservableObject` constraint implies reference semantics) and can be used directly with SwiftUI's `@StateObject` and `@ObservedObject` property wrappers.

### Usage

```swift
class ProfileViewModel: ViewModel {
    @Published var name: String = ""
    @Published var isLoading: Bool = false

    func load() async {
        isLoading = true
        name = await fetchProfile()
        isLoading = false
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        Text(viewModel.name)
    }
}
```

### Purpose

Adopting `ViewModel` instead of `ObservableObject` directly makes intent explicit in the type system and allows writing generic constraints over view models:

```swift
func makeView<VM: ViewModel>(for viewModel: VM) -> some View { ... }
```
