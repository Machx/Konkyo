# Extensions

Konkyo adds small, focused extensions to several standard and system types.

---

## NSLock

**File:** `Extensions/NSLockExtensions.swift`

```swift
extension NSLock {
    func tryLock(_ withLock: () -> Void)
}
```

Attempts to acquire the lock without blocking. If successful, executes the closure and then unlocks. If the lock is already held, the call is a no-op.

```swift
let lock = NSLock()
lock.tryLock {
    // only runs if the lock was free
}
```

---

## Result

**File:** `Extensions/ResultExtensions.swift`

```swift
extension Result {
    var failureError: Failure? { get }
}
```

Extracts the associated error from a `.failure` case, or returns `nil` for `.success`. Useful in `guard`/`else` branches where pattern matching is already exhausted.

```swift
let result = await fetchData()
guard case .success = result else {
    if let error = result.failureError {
        logger.error("\(error)")
    }
    return
}
```

---

## String (Networking)

**File:** `Networking/NetworkingExtensions.swift`

```swift
extension String {
    var isValidURL: Bool { get }
}
```

Returns `true` when the string can be parsed as a `URL` by `Foundation`.

```swift
"https://example.com".isValidURL  // true
"not a url $$".isValidURL         // false
```

---

## UIApplication (iOS only)

**File:** `Extensions/UIApplicationExtensions.swift`  
**Availability:** UIKit only (`#if canImport(UIKit)`)

```swift
extension UIApplication {
    func getKeyWindow() -> UIWindow?
}
```

Returns the first `UIWindow` in the foreground-active scene, or `nil` if none can be found. Avoids the deprecated `keyWindow` property.

```swift
let window = UIApplication.shared.getKeyWindow()
```

---

## View (SwiftUI)

**File:** `SwiftUI/ViewExtension.swift`

```swift
extension View {
    var typeErased: AnyView { get }
}
```

Type-erases any `View` to `AnyView`. Shorthand for `AnyView(self)`.

```swift
let erased: AnyView = MyCustomView().typeErased
```
