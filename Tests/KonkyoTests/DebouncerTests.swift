///
/// Copyright 2024 Colin Wheeler
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

import Konkyo
import Testing
import Foundation

/// Disable the Debouncer Tests for now until the RunLoop issues
/// can be resolved, and the tests pass more consistently.

@Suite("Debouncer Queue Tests")
struct DebouncerQueueTests {

	/// Verifies that the action fires on the queue passed to init(), not .main.
	@Test("init() dispatches action on the initialized queue")
	func testInitUsesInitializedQueue() async throws {
		let queueKey = DispatchSpecificKey<Bool>()
		let customQueue = DispatchQueue(label: "com.konkyo.test.debouncer.init")
		customQueue.setSpecific(key: queueKey, value: true)

		nonisolated(unsafe) var actionRanOnCustomQueue = false

		await confirmation("Action fires on the initialized queue") { fired in
			// Must retain the debouncer — its timer event handler captures self
			// weakly, so `let _ = Debouncer(…)` would let it deinit before firing.
			let debouncer = Debouncer(delay: 0.05, queue: customQueue) {
				actionRanOnCustomQueue = DispatchQueue.getSpecific(key: queueKey) == true
				fired()
			}
			try? await Task.sleep(for: .milliseconds(300))
			_ = debouncer
		}

		#expect(actionRanOnCustomQueue)
	}

	/// Verifies that after reset(), the action still fires on the queue passed to init(),
	/// not on .main (which was the bug before the fix).
	@Test("reset() dispatches action on the initialized queue, not main")
	func testResetUsesInitializedQueue() async throws {
		let queueKey = DispatchSpecificKey<Bool>()
		let customQueue = DispatchQueue(label: "com.konkyo.test.debouncer.reset")
		customQueue.setSpecific(key: queueKey, value: true)

		nonisolated(unsafe) var actionRanOnCustomQueue = false

		await confirmation("Action fires on the initialized queue after reset") { fired in
			let debouncer = Debouncer(delay: 0.05, queue: customQueue) {
				actionRanOnCustomQueue = DispatchQueue.getSpecific(key: queueKey) == true
				fired()
			}
			debouncer.reset()
			try? await Task.sleep(for: .milliseconds(300))
		}

		#expect(actionRanOnCustomQueue)
	}
}

@Suite("Debouncer Tests")
struct DebouncerTests {
	@Test("Test basic debouncer API")
	func testDebouncer() async throws {
		await confirmation("Confirm debouncedSignal is never called",
						   expectedCount: 0) { debouncedSignal in
			let bouncer = Debouncer(delay: 0.1) {
				debouncedSignal()
			}
			for _ in 0...1000 {
				bouncer.reset()
			}
			bouncer.cancel()
			// Wait past the delay so any erroneous firing would be observed.
			try? await Task.sleep(for: .milliseconds(300))
			_ = bouncer
		}
	}

	@Test("Test cancel action in Debouncer")
	func testCancelAction() async throws {
		await confirmation("Cancel action fires once when cancel() is called",
						   expectedCount: 1) { confirmCancel in
			let bouncer = Debouncer(delay: 0.5) {
				// Event action — should not fire because we cancel before delay elapses.
			} cancelAction: {
				confirmCancel()
			}
			bouncer.cancel()
			// Give the cancel handler time to dispatch onto its queue and run.
			try? await Task.sleep(for: .milliseconds(200))
			_ = bouncer
		}
	}

	@Test("Test Debouncer with multiple cancels")
	func testMultipleCancels() async throws {
		await confirmation("Three resets trigger cancel action three times",
						   expectedCount: 3) { confirm in
			let bouncer = Debouncer(delay: 0.5) {
				// Event action — should not fire within the test window.
			} cancelAction: {
				confirm()
			}
			bouncer.reset()
			bouncer.reset()
			bouncer.reset()
			// Give all three cancel handlers time to dispatch and run.
			try? await Task.sleep(for: .milliseconds(200))
			_ = bouncer
		}
	}

	@Test("cancelAction does not fire when event completes normally")
	func testCancelActionNotFiredOnNormalCompletion() async throws {
		let eventFired = Atomic(false)
		let cancelFired = Atomic(false)
		let bouncer = Debouncer(delay: 0.05) {
			eventFired.mutate { $0 = true }
		} cancelAction: {
			cancelFired.mutate { $0 = true }
		}
		// Wait well past the delay so the event handler runs and its
		// internal timer.cancel() completes.
		try? await Task.sleep(for: .milliseconds(300))
		#expect(eventFired.value == true)
		#expect(cancelFired.value == false)
		_ = bouncer
	}

	@Test("Test Reset after Cancel")
	func testResetAfterCancel() async {
		let bounceActionCompleted = Atomic(false)
		let cancelActionCompleted = Atomic(false)
		let bouncer = Debouncer(delay: 0.2) {
			bounceActionCompleted.mutate { $0 = true }
		} cancelAction: {
			cancelActionCompleted.mutate { $0 = true }
		}
		// Cancellation triggers the cancel handler.
		bouncer.cancel()
		try? await Task.sleep(for: .milliseconds(200))
		#expect(cancelActionCompleted.value == true)

		// reset() after cancel — the new timer should fire its action.
		bouncer.reset()
		try? await Task.sleep(for: .milliseconds(500))
		#expect(bounceActionCompleted.value == true)
		_ = bouncer
	}

	@Test("Event action fires exactly once after the delay elapses without reset")
	func testEventFiresOnceWhenLeftAlone() async throws {
		await confirmation("Action fires exactly once after the delay", expectedCount: 1) { fired in
			let bouncer = Debouncer(delay: 0.05) {
				fired()
			}
			try? await Task.sleep(for: .milliseconds(400))
			_ = bouncer
		}
	}

	@Test("Default queue (none provided) still fires the action")
	func testDefaultQueueFiresAction() async throws {
		let actionFired = Atomic(false)
		// Use the default-queue init to exercise that code path.
		let bouncer = Debouncer(delay: 0.05) {
			actionFired.mutate { $0 = true }
		}
		try? await Task.sleep(for: .milliseconds(300))
		#expect(actionFired.value == true)
		_ = bouncer
	}

}
