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

public final class Condition: @unchecked Sendable {
	fileprivate let mutex = Mutex()
	fileprivate var cond: UnsafeMutablePointer<pthread_cond_t>
	
	/// Name describing the condition. Used in debug logs.
	///
	/// 1.0.0
	public let name: String?
	
	public init(name: String? = nil) {
		self.name = name
		cond = UnsafeMutablePointer<pthread_cond_t>.allocate(capacity: 1)
		pthread_cond_init(cond, nil)
	}
	
	deinit {
		pthread_cond_destroy(cond)
		cond.deinitialize(count: 1)
		cond.deallocate()
	}
	
	/// Begins waiting on the condition, blocking the thread.
	///
	/// 1.0.0
	public func wait() {
		pthread_cond_wait(cond, mutex.pointer)
	}
	
	/// Intervals at or beyond this many seconds (about 31 years) are treated as "wait forever",
	/// which also keeps the nanosecond conversion in `relativeTimeSpec` from overflowing.
	private static let maxTimedWaitInterval: TimeInterval = 1_000_000_000
	
	private func relativeTimeSpec(forInterval interval: TimeInterval) -> timespec {
		let seconds = interval.rounded(.down)
		let nanoseconds = (interval - seconds) * 1_000_000_000
		return timespec(tv_sec: Int(seconds), tv_nsec: Int(nanoseconds))
	}
	
	/// Waits until the given date, blocking the thread, returns if the condition was unlocked.
	///
	/// This function additionally may return false for other reasons including:
	/// - Date is in the past.
	/// - Date was unable to be converted to its timespec type equivalent.
	///
	/// The wait is measured against a relative interval from "now" so it is
	/// unaffected by changes to the system wall clock.
	///
	/// 1.0.0
	public func wait(until waitDate: Date = Date.distantFuture) -> Bool {
		let interval = waitDate.timeIntervalSinceNow
		guard interval > 0 else { return false }
		guard interval < Self.maxTimedWaitInterval else {
			pthread_cond_wait(cond, mutex.pointer)
			return true
		}
		var reltime = relativeTimeSpec(forInterval: interval)
		return pthread_cond_timedwait_relative_np(cond, mutex.pointer, &reltime) == 0
	}
	
	/// Runs `body` while holding the condition's lock, unlocking afterwards even if `body` throws.
	///
	/// - Parameter body: The closure to execute while the lock is held.
	/// - Returns: The value returned by `body`.
	public func withLock<R>(_ body: () throws -> R) rethrows -> R {
		lock()
		defer { unlock() }
		return try body()
	}
	
	/// Waits until `predicate` returns false, guarding against spurious wakeups.
	///
	/// The lock must be held by the calling thread, as with `wait()`. The predicate is
	/// evaluated with the lock held.
	/// - Parameter predicate: Returns true while the caller should keep waiting.
	public func wait(while predicate: () -> Bool) {
		while predicate() {
			wait()
		}
	}
	
	/// Waits until `predicate` returns false or the date passes, guarding against spurious wakeups.
	///
	/// The lock must be held by the calling thread, as with `wait(until:)`.
	/// - Returns: True if the predicate became false, false if the date passed first.
	public func wait(until waitDate: Date, while predicate: () -> Bool) -> Bool {
		while predicate() {
			guard wait(until: waitDate) else { return !predicate() }
		}
		return true
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

extension Condition: CustomDebugStringConvertible {
	public var debugDescription: String {
		let description = "Condition(\(name ?? String(describing: ObjectIdentifier(self))))"
		return description
	}
}

extension Condition: Equatable, Hashable {
	public static func == (lhs: Condition, rhs: Condition) -> Bool {
		lhs === rhs
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}

extension Condition: NSLocking {
	public func unlock() {
		mutex.unlock()
	}
	
	public func lock() {
		mutex.lock()
	}
}
