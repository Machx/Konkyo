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

@available(macOS 10.12,iOS 10.10, macCatalyst 13.0, tvOS 10.0, watchOS 3.0, *)
/// Simple wrapper around os_unfair_lock
///
/// Konkyo 0.2.0
public final class UnfairLock {
	
	private var unfairLock = os_unfair_lock()
	
	public init() {
	}
	
	public func lock() {
		os_unfair_lock_lock(&unfairLock)
	}
	
	public func unlock() {
		os_unfair_lock_unlock(&unfairLock)
	}
	
	public func tryLock() -> Bool {
		return os_unfair_lock_trylock(&unfairLock)
	}
}
