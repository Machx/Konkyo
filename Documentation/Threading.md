# Threading

Konkyo provides four threading primitives covering atomic access, mutual exclusion, condition-variable signalling, and async operation lifecycle management.

---

## Atomic\<Value\>

`Atomic<Value>` wraps any value and serializes all reads and writes through a private serial `DispatchQueue`, making the wrapped value safe to access from multiple threads.

```swift
let counter = Atomic(0)

// Thread-safe read
let current = counter.value

// Thread-safe mutation
counter.mutate { $0 += 1 }
```

**Notes:**
- Do not read via `.value` and then immediately call `.mutate` expecting the value not to have changed. Use `mutate` to both read and write atomically.
- Conforms to `Sendable` (marked `@unchecked` because the queue serializes access).

---

## Mutex

`Mutex` is a thin, direct wrapper around `pthread_mutex_t`. It supports both normal and recursive initialization.

```swift
let mutex = Mutex()            // normal mutex (default)
let recursive = Mutex(type: .recursive)

// Manual lock/unlock
mutex.lock()
defer { mutex.unlock() }

// Convenience with closure
mutex.withLock {
    // critical section
}

// Non-blocking attempt
if mutex.tryLock() {
    defer { mutex.unlock() }
    // ...
}

// Attempt + closure shorthand
mutex.tryLock {
    // only runs if the lock was acquired
}
```

**Notes:**
- Unlocking from a thread that did not acquire the lock is undefined behavior (matches `pthread_mutex_t` semantics).
- Properly destroys and deallocates the underlying pointer on `deinit`.
- Conforms to `Sendable` (marked `@unchecked`).

---

## Condition

`Condition` wraps a `pthread_cond_t` / `pthread_mutex_t` pair. It conforms to `NSLocking`, `Equatable`, `Hashable`, and `CustomDebugStringConvertible`.

```swift
let condition = Condition()
condition.name = "myCondition"  // optional, used in debug output

// On the waiting thread — must hold the mutex first
condition.lock()
condition.wait()                // blocks indefinitely
condition.unlock()

// Timed wait — returns false on timeout or date in the past
condition.lock()
let signalled = condition.wait(until: Date().addingTimeInterval(5))
condition.unlock()

// On the signalling thread
condition.signal()     // wake one waiter
condition.broadcast()  // wake all waiters
```

**Notes:**
- Each `Condition` instance has a stable `UUID` used for identity (`Equatable`) and hashing.
- If a `name` is set it is included in the hash.

---

## AsynchronousOperationBase

`AsynchronousOperationBase` is an `Operation` subclass that handles the boilerplate for asynchronous operations: it overrides `isAsynchronous` to return `true` and provides settable `isExecuting` / `isFinished` properties that automatically fire the required KVO notifications.

```swift
class MyOperation: AsynchronousOperationBase {
    override func start() {
        isExecuting = true
        Task {
            await doWork()
            isExecuting = false
            isFinished = true
        }
    }
}
```

**Notes:**
- Subclasses must call `isExecuting = false; isFinished = true` to complete the operation and allow the owning `OperationQueue` to proceed.
- Setting a property to its current value is a no-op (guarded with `guard != newValue`).
