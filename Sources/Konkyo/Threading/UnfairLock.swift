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

import Foundation

/// Simple wrapper around os_unfair_lock
///
/// Konkyo 0.2.0
public final class UnfairLock {
	
	private var unfairLock:  UnsafeMutablePointer<os_unfair_lock>
	
	public init() {
		unfairLock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
		unfairLock.initialize(to: os_unfair_lock())
	}

	deinit {
		unfairLock.deallocate()
	}
	
	/// Locks the unfair lock
	public func lock() {
		os_unfair_lock_lock(unfairLock)
	}
	
	/// Unlocks the unfair lock
	public func unlock() {
		os_unfair_lock_unlock(unfairLock)
	}
	
	/// Attempts to lock the unfair lock
	///
	/// If this function returns false the program must be able to continue
	/// not having acquired the lock, or call `lock` directly.
	public func tryLock() -> Bool {
		os_unfair_lock_trylock(unfairLock)
	}
}
