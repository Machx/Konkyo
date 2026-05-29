# Utilities

---

## Debouncer

**File:** `Debouncer.swift`

`Debouncer` delays an action until it has gone uninterrupted for a specified duration. Each call to `reset()` restarts the delay. This is useful for coalescing rapid events such as search-field keystrokes or scroll position updates.

```swift
let debouncer = Debouncer(delay: 0.3, queue: .main) {
    performSearch(query)
}

// Call reset() each time the input changes; the search only fires
// once the user stops typing for 300 ms.
textField.onTextChange { _ in
    debouncer.reset()
}
```

### Initializer

```swift
init(
    delay: Double,
    queue: DispatchQueue = .global(qos: .background),
    _ eventHandler: @escaping DebouncerAction,
    cancelAction: DebouncerAction? = nil
)
```

| Parameter      | Description                                              |
| -------------- | -------------------------------------------------------- |
| `delay`        | Seconds to wait before firing the action                 |
| `queue`        | Serial `DispatchQueue` for handler execution             |
| `eventHandler` | Called once after the delay elapses without interruption |
| `cancelAction` | Called every time the debouncer is reset or cancelled    |

### Methods

| Method     | Description                                            |
| ---------- | ------------------------------------------------------ |
| `reset()`  | Cancels the current timer and starts a new one         |
| `cancel()` | Cancels the current timer without scheduling a new one |

### Notes

- The queue **must** be serial. Using a concurrent queue can cause the event and cancel handlers to fire more than once.
- The timer starts immediately on `init`; call `reset()` to restart the delay window.

---

## Initialization Operator (`<-`)

**File:** `Initialization.swift`

The `<-` infix operator passes an object to a configuration closure and returns the object. It is an alternative to immediately-invoked closure expressions (IICEs) for configuring objects inline.

```swift
// Before
let button: UIButton = {
    let b = UIButton()
    b.setTitle("OK", for: .normal)
    b.backgroundColor = .systemBlue
    return b
}()

// With <- 
let button = UIButton() <- {
    $0.setTitle("OK", for: .normal)
    $0.backgroundColor = .systemBlue
}
```

The operator is generic over `T` and returns the same instance passed in, so the type is inferred automatically.

---

## CPUInfo

**File:** `System Info/CPUInfo.swift`

`CPUInfo` queries the system for hardware information via `sysctl`.

```swift
let info = CPUInfo()
let cores = info.cpuCoreCount()  // e.g. 10
```

### SysctlProviding Protocol

The underlying sysctl queries are abstracted behind `SysctlProviding`, making `CPUInfo` testable without touching real hardware:

```swift
public protocol SysctlProviding {
    func sysctlInt(for name: String) -> Int
}
```

`RealSysctlProvider` is the production conformer. In tests, provide a mock:

```swift
struct MockSysctlProvider: SysctlProviding {
    func sysctlInt(for name: String) -> Int { 8 }
}

let info = CPUInfo(sysctlProvider: MockSysctlProvider())
```
