///
/// Copyright 2020 Colin Wheeler
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import Darwin.POSIX.pthread

/// Simple wrapper around the pthread_mutex_t c api.
public final class Mutex: @unchecked Sendable {
	/// Type used to initialize the underlying mutex.
	public enum MutexType {
		// Initializes the Mutex to a normal mutex. This is the default.
		case normal
		// Initializes the Mutex to be recursive for the same thread.
		case recursive
	}
	
	/// The underlying pthread mutex. Internal so `Condition` can pass it to `pthread_cond_wait`.
	let pointer = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
	
	/// Initializes the Mutex. If desired the type can be set to allow for creating a recursive mutex.
	/// - Parameter type: The type of mutex. The default is normal, but .recursive can be set to allow a recursive mutex.
	public init(type: MutexType = .normal) {
		var attributes = pthread_mutexattr_t()
		pthread_mutexattr_init(&attributes)
		defer { pthread_mutexattr_destroy(&attributes) }
		switch type {
		case .normal:
			pthread_mutexattr_settype(&attributes, PTHREAD_MUTEX_NORMAL)
		case .recursive:
			pthread_mutexattr_settype(&attributes, PTHREAD_MUTEX_RECURSIVE)
		}
		pthread_mutex_init(pointer, &attributes)
	}
	
	deinit {
		pthread_mutex_destroy(pointer)
		pointer.deinitialize(count: 1)
		pointer.deallocate()
	}
	
	/// Locks the mutex if it is unlocked. If it is locked then it blocks until unlocked.
	public func lock() {
		pthread_mutex_lock(pointer)
	}
	
	/// Unlocks the mutex. If you try to unlock the mutex from a thread that didn't lock it, it is undefined behavior.
	///
	/// See `pthread_mutex_t` for more information on the undefined behavior aspect of this api.
	public func unlock() {
		pthread_mutex_unlock(pointer)
	}
	
	/// Tries to lock the mutex while not blocking the current thread until the lock is acquired.
	///
	/// - returns: True if the lock was acquired, false if the lock could not be acquired.
	public func tryLock() -> Bool {
		return pthread_mutex_trylock(pointer) == 0
	}

	/// Locks the mutex, executes the body, and unlocks the mutex.
	///
	/// The mutex is unlocked even if the body throws.
	/// - Parameter body: The closure to execute while the lock is held.
	/// - Returns: The value returned by `body`.
	public func withLock<R>(_ body: () throws -> R) rethrows -> R {
		lock()
		defer { unlock() }
		return try body()
	}
	
	/// Tries to lock the mutex, and if it succeeds executes the body and unlocks the mutex.
	///
	/// If the lock is unavailable the body will not execute and `nil` is returned.
	/// The mutex is unlocked even if the body throws.
	/// - Parameter body: The closure to execute if the lock is acquired.
	/// - Returns: The value returned by `body`, or `nil` if the lock could not be acquired.
	@discardableResult
	public func tryLock<R>(_ body: () throws -> R) rethrows -> R? {
		guard tryLock() else { return nil }
		defer { unlock() }
		return try body()
	}
}
