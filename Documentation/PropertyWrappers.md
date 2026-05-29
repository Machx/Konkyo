# Property Wrappers

## @Preferences\<Value\>

**File:** `PropertyWrappers/Settings.swift`

`@Preferences` is a property wrapper that stores any `Codable` value in `UserDefaults`, using JSON encoding/decoding as the serialization format.

```swift
@Preferences(key: "username", defaultValue: "")
var username: String

@Preferences(key: "fontSize", defaultValue: 14.0)
var fontSize: Double
```

Reading returns the stored value decoded from `UserDefaults`, or `defaultValue` if the key is absent or decoding fails. Writing encodes the new value with `JSONEncoder` and saves it.

### Initializer

```swift
init(key: String, defaultValue: Value, userDefaults: UserDefaultsProtocol = UserDefaults.standard)
```

The `userDefaults` parameter accepts any conformer to `UserDefaultsProtocol`, making the wrapper testable without touching the real `UserDefaults`.

### UserDefaultsProtocol

```swift
public protocol UserDefaultsProtocol {
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
}
```

`UserDefaults` conforms to this protocol automatically via an extension in Konkyo.

### Notes

- Value types must conform to `Codable`.
- Encoding failures are silent; the value is not persisted if encoding throws.
- Decoding failures fall back to `defaultValue`.
