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

/// Provides Thread Safe Atomic access to a variable
///
/// 1.0.0
public final class Atomic<Value> {
	private var _value: Value
	private let queue = DispatchQueue(label: "com.Konkyo.Atomic.\(String(describing: Value.self))")
	
	public init(_ value: Value) {
		self._value = value
	}
	
	/// Safely Reads the value and returns the value in a thread safe manner.
	///
	/// - returns: The wrapped value in a thread safe manner.
	/// 1.0.0
	public var value: Value {
		get { return queue.sync { self._value } }
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
		queue.sync {
			transform(&self._value)
		}
	}
}
