# Konkyo

Konkyo is a small, focused Swift package containing common utilities used across Apple platform projects. It targets macOS 15+ and iOS 18+, and is built with Swift 6 concurrency in mind.

## License

Apache License, Version 2.0. Copyright 2019 Colin Wheeler.

## Package Dependencies

- [LoggingKit](https://github.com/Machx/LoggingKit) — used internally for debug logging in data structures.

## Categories

| Category | Description |
|---|---|
| [Threading](Threading.md) | Low-level synchronization primitives and async operation base class |
| [Data Structures](DataStructures.md) | Bounded rolling dictionary |
| [Extensions](Extensions.md) | Extensions on Foundation and SwiftUI types |
| [Property Wrappers](PropertyWrappers.md) | `UserDefaults`-backed preferences property wrapper |
| [MVVM](MVVM.md) | Protocol for SwiftUI view models |
| [Utilities](Utilities.md) | Debouncer, initialization operator, and CPU info |

## Source Layout

```
Sources/Konkyo/
├── Data Structures/
│   └── RollingDictionary.swift
├── Extensions/
│   ├── NSLockExtensions.swift
│   ├── ResultExtensions.swift
│   └── UIApplicationExtensions.swift
├── MVVM/
│   └── ViewModel.swift
├── Networking/
│   └── NetworkingExtensions.swift
├── PropertyWrappers/
│   └── Settings.swift
├── SwiftUI/
│   └── ViewExtension.swift
├── System Info/
│   └── CPUInfo.swift
├── Threading/
│   ├── AsynchronousOperationBase.swift
│   ├── Atomic.swift
│   ├── Condition.swift
│   └── Mutex.swift
├── Debouncer.swift
└── Initialization.swift
```
