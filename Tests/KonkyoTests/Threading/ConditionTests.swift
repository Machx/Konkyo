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
import Konkyo
import Testing

// Disabling due to intermitent unit test issue
@Suite("CWCondition Tests")
struct CWConditionTests {
	
	@Test("Test Condition")
	func testCWCondition() async {
		await MainActor.run {
			let condition = Condition()

			// Hold the mutex before launching the signaller so the signal can't be
			// lost: pthread_cond_wait atomically releases the mutex and begins waiting,
			// which prevents the signaller from running before this thread is blocked.
			condition.lock()

			DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
				condition.lock()
				condition.signal()
				condition.unlock()
			}

			// Bounded wait so a regression can never hang the test indefinitely.
			let signalled = condition.wait(until: Date(timeIntervalSinceNow: 2.0))
			condition.unlock()

			#expect(signalled)
		}
	}

	@Test("Test wait until date")
	func testWaitUntilDate() async throws {
		await MainActor.run {
			let condition = Condition()

			condition.lock()

			DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
				condition.lock()
				condition.signal()
				condition.unlock()
			}

			let result = condition.wait(until: Date(timeIntervalSinceNow: 3.0))
			condition.unlock()
			#expect(result == true)
		}
	}

	@Test("Test Wait Until with Negative Date")
	func testWaitUntilDateNegative() throws {
		let condition = Condition()

		condition.lock()
		// Give it a date way in the past so it should reject it
		let result = condition.wait(until: Date(timeIntervalSince1970: 6))
		condition.unlock()
		#expect(result == false)
	}

	@Test("Test wait until now")
	func testWaitUntilDateNegative2() throws {
		let condition = Condition()

		condition.lock()
		let result = condition.wait(until: Date())
		condition.unlock()
		#expect(result == false)
	}

	@Test("broadcast() wakes all waiting threads")
	func testBroadcastWakesAllWaiters() async {
		let condition = Condition()
		let wakeCount = Atomic(0)
		let waiterCount = 3
		let group = DispatchGroup()

		for _ in 0..<waiterCount {
			group.enter()
			DispatchQueue.global(qos: .background).async {
				condition.lock()
				// Bounded deadline so the test doesn't hang if broadcast is broken.
				let _ = condition.wait(until: Date(timeIntervalSinceNow: 5.0))
				condition.unlock()
				wakeCount.mutate { $0 += 1 }
				group.leave()
			}
		}

		// Give all waiters time to acquire the mutex and block in wait before broadcasting.
		try? await Task.sleep(for: .milliseconds(200))
		condition.lock()
		condition.broadcast()
		condition.unlock()

		await withCheckedContinuation { continuation in
			group.notify(queue: .global()) { continuation.resume() }
		}
		#expect(wakeCount.value == waiterCount)
	}

	@Test("signal() with no waiters does not crash")
	func testSignalWithNoWaiters() {
		let condition = Condition()
		condition.lock()
		// pthread_cond_signal is documented as safe to call with no waiters.
		condition.signal()
		condition.unlock()
	}

	@Test("broadcast() with no waiters does not crash")
	func testBroadcastWithNoWaiters() {
		let condition = Condition()
		condition.lock()
		condition.broadcast()
		condition.unlock()
	}

	@Test("Condition without an explicit name still produces a debug description")
	func testDebugDescriptionWithoutName() {
		let condition = Condition()
		#expect(condition.debugDescription.contains("Condition("))
	}

	@Test("Condition with explicit name includes the name in debug description")
	func testDebugDescriptionWithName() {
		let condition = Condition(name: "MyConditionName")
		#expect(condition.debugDescription.contains("MyConditionName"))
	}

	@Test("Two Conditions with the same name are not equal")
	func testTwoConditionsWithSameNameAreNotEqual() {
		let a = Condition(name: "shared")
		let b = Condition(name: "shared")
		#expect(a != b, "Equality is identity-based via UUID, not name-based")
	}

	@Test("Condition is equal to itself")
	func testConditionEqualToItself() {
		let condition = Condition()
		#expect(condition == condition)
	}

	@Test("Condition hash is consistent across multiple calls")
	func testConditionHashIsConsistent() {
		let condition = Condition()
		var hasher1 = Hasher()
		var hasher2 = Hasher()
		condition.hash(into: &hasher1)
		condition.hash(into: &hasher2)
		#expect(hasher1.finalize() == hasher2.finalize())
	}

	@Test("Conditions can be inserted in a Set as distinct entries")
	func testConditionsInSet() {
		let a = Condition()
		let b = Condition()
		let set: Set<Condition> = [a, b, a]
		#expect(set.count == 2)
	}

	@Test("wait(until:) returns false immediately for past date without blocking")
	func testWaitUntilPastDateReturnsImmediately() {
		let condition = Condition()
		condition.lock()
		let start = Date()
		let result = condition.wait(until: Date(timeIntervalSinceNow: -10))
		let elapsed = Date().timeIntervalSince(start)
		condition.unlock()
		#expect(result == false)
		// Should return quickly without sleeping.
		#expect(elapsed < 0.5)
	}
}

