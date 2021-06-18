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
public final class Mutex {
	/// Type used to initialize the underlying mutex.
	public enum MutexType {
		// Initializes the Mutex to a normal mutex. This is the default.
		case normal
		// Initializes the Mutex to be recursive for the same thread.
		case recursive
	}
	
	private typealias _MutexPointer = UnsafeMutablePointer<pthread_mutex_t>
	private typealias _MutexAttributesPointer = UnsafeMutablePointer<pthread_mutexattr_t>
	
	private var mutex = _MutexPointer.allocate(capacity: 1)
	private var mutexAttr = _MutexAttributesPointer.allocate(capacity: 1)
	
	/// Initializes the Mutex. If desired the type can be set to allow for creating a recursive mutex.
	/// - Parameter type: The type of mutex. The default is normal, but .recursive can be set to allow a recursive mutex.
	public init(type: MutexType = .normal) {
		pthread_mutexattr_init(mutexAttr)
		switch type {
		case .normal:
			pthread_mutexattr_settype(mutexAttr, PTHREAD_MUTEX_NORMAL)
		case .recursive:
			pthread_mutexattr_settype(mutexAttr, PTHREAD_MUTEX_RECURSIVE)
		}
		pthread_mutex_init(mutex, mutexAttr)
		pthread_mutexattr_destroy(mutexAttr)
		mutexAttr.deinitialize(count: 1)
		mutexAttr.deallocate()
	}
	
	deinit {
		pthread_mutex_destroy(mutex)
		mutex.deinitialize(count: 1)
		mutex.deallocate()
	}
	
	/// Locks the mutex if it is unlocked. If it is locked then it blocks until unlocked.
	public func lock() {
		pthread_mutex_lock(mutex)
	}
	
	/// Unlocks the mutex. If you try to unlock the mutex from a thread that didnt lock it, it is undefined behavior.
	///
	/// See `pthread_mutex_t` for more infomration on the undefined behavior aspect of this api.
	public func unlock() {
		pthread_mutex_unlock(mutex)
	}
	
	/// Tries to lock the mutex while not blocking the current thread until the lock is acequired.
	///
	/// - returns: True if the lock was acquired, false if the lock could not be acquired.
	public func tryLock() -> Bool {
		return pthread_mutex_trylock(mutex) == 0
	}
}
