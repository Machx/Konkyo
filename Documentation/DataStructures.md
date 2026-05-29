# Data Structures

## RollingDictionary\<Key, Value\>

`RollingDictionary` is a value-type dictionary that enforces a maximum number of stored key/value pairs. When the limit is exceeded, the oldest entries (by insertion order) are evicted automatically.

```swift
// Unlimited (default, limit = Int.max)
var cache: RollingDictionary<String, Int> = ["a": 1, "b": 2]

// Bounded to the last 3 entries
var recent = RollingDictionary<String, String>(limit: 3)
recent["first"]  = "one"
recent["second"] = "two"
recent["third"]  = "three"
recent["fourth"] = "four"   // evicts "first"

print(recent["first"])   // nil
print(recent["fourth"])  // Optional("four")
```

### API Summary

| Member                     | Description                                             |
| -------------------------- | ------------------------------------------------------- |
| `init()`                   | Unlimited dictionary                                    |
| `init(limit:)`             | Bounded dictionary with the given key limit             |
| `init(dictionaryLiteral:)` | Dictionary literal support (unlimited)                  |
| `subscript(key:)`          | Get or set values; setting `nil` removes the key        |
| `keys`                     | Returns the underlying dictionary's `Keys` collection   |
| `getKeyLimit() -> Int`     | Returns the current limit                               |
| `setLimit(_:)`             | Updates the limit and immediately evicts excess entries |

### Eviction Behaviour

- Insertion order is tracked internally via a separate `Array<Key>`.
- When the key count exceeds the limit, the oldest key(s) are removed first.
- Updating an existing key does **not** change its insertion-order position.
- Setting a key to `nil` removes it without triggering eviction logic.

### Notes

- Conforms to `ExpressibleByDictionaryLiteral`.
- Key type must be `Hashable`; value type is unconstrained.
- Eviction events are logged at the `debug` level via LoggingKit.
