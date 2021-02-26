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
import Darwin

@available(OSX 10.12,iOS 6, *)
public final class Condition {
	fileprivate var uuid = UUID()
	
	fileprivate var mutex: UnsafeMutablePointer<pthread_mutex_t>
	fileprivate var cond: UnsafeMutablePointer<pthread_cond_t>
	
	/// Name describing the condition. Used in debug logs.
	///
	/// 1.0.0
	public var name: String? = nil
	
	public init() {
		cond = UnsafeMutablePointer<pthread_cond_t>.allocate(capacity: 1)
		mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
		pthread_cond_init(cond, nil)
		pthread_mutex_init(mutex, nil)
	}
	
	/// Begins waiting on the condition, blocking the thread.
	///
	/// 1.0.0
	public func wait() {
		pthread_cond_wait(cond, mutex)
	}
	
	private func timeSpecFrom(date: Date) -> timespec? {
		guard date.timeIntervalSinceNow > 0 else {
			return nil
		}
		let nsecPerSec: Int64 = 1_000_000_000
		let interval = date.timeIntervalSince1970
		let intervalNS = Int64(interval * Double(nsecPerSec))

		return timespec(tv_sec: Int(intervalNS / nsecPerSec),
						tv_nsec: Int(intervalNS % nsecPerSec))
	}
	
	/// Waits until the given date, returns if the condition was unlocked.
	///
	/// 1.0.0
	public func wait(until: Date) -> Bool {
		guard var untilSpec = timeSpecFrom(date: until) else { return false }
		return pthread_cond_timedwait(cond, mutex, &untilSpec) == 0
	}
	
	/// Signals the condition, unlocking the thread waiting on it.
	///
	/// 1.0.0
	public func signal() {
		pthread_cond_signal(cond)
	}
	
	/// Broadcasts the condition, unlocking all threads waiting on it.
	///
	/// 1.0.0
	public func broadcast() {
		pthread_cond_broadcast(cond)
	}
}

@available(OSX 10.12,iOS 6, *)
extension Condition: CustomDebugStringConvertible {
	public var debugDescription: String {
		let customName = uuid.uuidString
		let description = "CWCondition(\(customName))"
		return description
	}
}

@available(OSX 10.12,iOS 6, *)
extension Condition: Equatable, Hashable {
	public static func == (lhs: Condition, rhs: Condition) -> Bool {
		lhs.uuid == rhs.uuid
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
		if let name = name {
			hasher.combine(name)
		}
	}
}

@available(OSX 10.12,iOS 6, *)
extension Condition: NSLocking {
	public func unlock() {
		pthread_mutex_unlock(mutex)
	}
	
	public func lock() {
		pthread_mutex_lock(mutex)
	}
}