///
/// Copyright 2019 Colin Wheeler
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

@available(OSX 10.12, *)
@propertyWrapper
public final class Atomic<Value> {
	public var value: Value
	//var lock = os_unfair_lock()
	//private var queue = DispatchQueue(label: "com.Konkyo.\(String(describing: Value.self))")
	var lock = NSRecursiveLock()
	
	public init(wrappedValue value: Value) {
		self.value = value
	}
	
	public var wrappedValue: Value {
		//get { queue.sync { value } }
		//set { queue.sync { value = newValue } }
//		get {
//			os_unfair_lock_lock(&lock)
//			defer { os_unfair_lock_unlock(&lock) }
//			return value
//		}
//		set {
//			os_unfair_lock_lock(&lock)
//			defer { os_unfair_lock_unlock(&lock) }
//			value = newValue
//		}
		get {
			lock.lock()
			defer { lock.unlock() }
			return value
		}
		set {
			lock.lock()
			defer { lock.unlock() }
			value = newValue
		}
	}
}
