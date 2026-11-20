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
import Synchronization

/// Provides Thread Safe Atomic access to a variable
///
/// 1.0.0
public final class Atomic<Value>: @unchecked Sendable {
	// Backed by the standard library's `Synchronization.Mutex`, which stores the lock and the value
	// inline in this object. That makes an `Atomic` a single heap allocation, with no per-instance
	// DispatchQueue and no separately allocated pthread mutex. It is qualified with its module name
	// because this package defines its own `Mutex`.
	private let storage: Synchronization.Mutex<Box>

	/// `Synchronization.Mutex` requires `Sendable` values moving in and out of it. `Atomic` is
	/// `@unchecked Sendable` and accepts any `Value`, so the value is carried in this box. Access to
	/// the box is always serialized by the lock.
	private struct Box: @unchecked Sendable {
		var value: Value
	}

	public init(_ value: Value) {
		self.storage = Synchronization.Mutex(Box(value: value))
	}

	/// Safely Reads the value and returns the value in a thread safe manner.
	///
	/// - returns: The wrapped value in a thread safe manner.
	/// 1.0.0
	public var value: Value {
		storage.withLock { $0 }.value
	}

	/// Passes the value to you and allows you to safely mutate the value.
	///
	/// It is not recommended that you call this right after reading in the value.
	/// It is possible that the value can change between reading the value and mutation. If
	/// you must you can use this function to both read and quickly write the value. The value
	/// function is provided for those things that need only quick read only access.
	///
	/// - Parameter transform: a block in which the value is passed to you for safe mutation.
	/// 1.0.0
	public func mutate(_ transform: (inout Value) -> Void) {
		storage.withLock { transform(&$0.value) }
	}
}
