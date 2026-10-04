# Traceable Errors

**File:** `Errors.swift`

Errors are often wrapped as they travel up through layers of an app: a database error is wrapped by a profile error, which is wrapped by an app-level error. By the time you log the outermost one, the root cause is hidden. `TraceableError` makes each wrapper expose the error it contains, and `traceableErrorDescription()` walks that chain to print the whole path.

```
AppError - loadingError
└─ ProfileError - noSavedProfileError
   └─ DatabaseError - noRecordFound
```

---

## The Protocol

```swift
public protocol TraceableError: Error {
    var containedError: Error { get }
}
```

A type conforms by returning the error it wraps. Typically that means an enum case with an associated value:

```swift
enum DatabaseError: Error {
    case noRecordFound
}

enum ProfileError: TraceableError {
    case noSavedProfileError(DatabaseError)

    var containedError: Error {
        switch self {
        case .noSavedProfileError(let error): return error
        }
    }
}

enum AppError: TraceableError {
    case loadingError(ProfileError)

    var containedError: Error {
        switch self {
        case .loadingError(let error): return error
        }
    }
}
```

The innermost ("leaf") error does not conform to `TraceableError`. It ends the chain.

---

## Printing the Chain

`traceableErrorDescription()` is an extension on every `Error`:

```swift
let error: Error = AppError.loadingError(.noSavedProfileError(.noRecordFound))
print(error.traceableErrorDescription())
```

```
AppError - loadingError
└─ ProfileError - noSavedProfileError
   └─ DatabaseError - noRecordFound
```

Calling it on an error that is not traceable is fine. It returns a single line.

### Line format

| Error kind                          | Line                          |
| ----------------------------------- | ----------------------------- |
| Enum                                | `TypeName - caseName`         |
| Struct, class, or other non-enum    | `TypeName - <String(describing:)>` |
| `NSError` (or subclass)             | `TypeName - domain (code)`    |

For enums, only the case name is shown, and associated values are left out. This keeps lines short and stops the wrapped error from being printed twice, once inline and once on its own line.

### Indentation

The first line has no prefix. Each deeper level adds `└─ `, and every level after the second is indented by three more spaces per level of depth, so the arrows line up under the text of the line above.

---

## How It Works

The method is a loop over the chain:

1. Format `current` (initially `self`) and append it to the output.
2. If `current` is a `TraceableError`, set `current = containedError` and continue.
3. Otherwise, if `current` is an `NSError` with an underlying error, continue with that.
4. Otherwise stop.
5. Join the lines with newlines.

Because it is iterative, a long chain cannot overflow the stack.

---

## NSError Support

`NSError` values are unwrapped even though they don't conform to `TraceableError`. The next link is the first of:

1. `underlyingErrors.first`
2. `userInfo[NSUnderlyingErrorKey]`, if the value is an `Error`

```swift
let inner = NSError(domain: "NSPOSIXErrorDomain", code: 2)
let outer = NSError(domain: NSCocoaErrorDomain, code: 260,
                    userInfo: [NSUnderlyingErrorKey: inner])
print(outer.traceableErrorDescription())
```

```
NSError - NSCocoaErrorDomain (260)
└─ NSError - NSPOSIXErrorDomain (2)
```

Notes:

- Only the **first** underlying error is followed. If there are several, the rest are not shown.
- If `NSUnderlyingErrorKey` holds something that isn't an `Error`, it is ignored and the chain ends.
- `NSError` and `TraceableError` can be mixed in either order. A `TraceableError` may wrap an `NSError`, and an `NSError` may wrap a `TraceableError`.
- Every Swift `Error` bridges to `NSError` on demand, so the code checks the error's *dynamic type* (`type(of: error) is NSError.Type`) rather than using `as? NSError`. Without this check, plain Swift errors would be misreported as `NSError` lines.

---

## Tests

`ErrorsTests.swift` covers non-traceable errors, chains of two to four levels, struct conformers, enum cases with multiple associated values, non-enum leaves, plain and subclassed `NSError`, multiple underlying errors, and mixed `TraceableError`/`NSError` chains.
