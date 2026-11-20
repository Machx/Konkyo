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

	@Test("reset() after the event has already fired arms a new timer that fires the event again")
	func testResetAfterFireFiresAgain() async throws {
		let fireCount = Atomic(0)
		let bouncer = Debouncer(delay: 0.05) {
			fireCount.mutate { $0 += 1 }
		}
		// Wait for the first firing.
		try? await Task.sleep(for: .milliseconds(200))
		#expect(fireCount.value == 1)

		// Reset schedules a new timer; expect the action to fire again.
		bouncer.reset()
		try? await Task.sleep(for: .milliseconds(200))
		#expect(fireCount.value == 2)
		_ = bouncer
	}

	@Test("cancel() without a configured cancel action does not crash")
	func testCancelWithoutCancelAction() async throws {
		let bouncer = Debouncer(delay: 0.5) { }
		bouncer.cancel()
		try? await Task.sleep(for: .milliseconds(100))
		_ = bouncer
	}

	@Test("Rapidly alternating reset and cancel does not invoke the event handler")
	func testRapidResetCancelDoesNotFire() async throws {
		await confirmation("Event never fires", expectedCount: 0) { fired in
			let bouncer = Debouncer(delay: 0.05) {
				fired()
			}
			for _ in 0..<50 {
				bouncer.reset()
				bouncer.cancel()
			}
			try? await Task.sleep(for: .milliseconds(300))
			_ = bouncer
		}
	}
}

@Suite("Debouncer Generation Tests")
struct DebouncerGenerationTests {

	@Test("Many rapid resets fire the action once and the cancel action once per superseded timer")
	func testRapidResetsAttributeCancelsToTheRightTimer() async throws {
		let actionCount = Atomic(0)
		let cancelCount = Atomic(0)
		let resets = 25
		let debouncer = Debouncer(delay: 0.15,
								  queue: DispatchQueue(label: "com.konkyo.test.debouncer.generation"),
								  { actionCount.mutate { $0 += 1 } },
								  cancelAction: { cancelCount.mutate { $0 += 1 } })
		for _ in 0..<resets { debouncer.reset() }
		try await Task.sleep(for: .milliseconds(500))

		// The initial timer plus every reset but the last were superseded before firing.
		#expect(actionCount.value == 1)
		#expect(cancelCount.value == resets)
		_ = debouncer
	}

	@Test("A timer that already fired does not report a cancel when a later reset supersedes it")
	func testFiredTimerIsNotCountedAsCancelled() async throws {
		let actionCount = Atomic(0)
		let cancelCount = Atomic(0)
		let debouncer = Debouncer(delay: 0.03,
								  queue: DispatchQueue(label: "com.konkyo.test.debouncer.generation.fired"),
								  { actionCount.mutate { $0 += 1 } },
								  cancelAction: { cancelCount.mutate { $0 += 1 } })
		try await Task.sleep(for: .milliseconds(200)) // first timer fires
		debouncer.reset()
		try await Task.sleep(for: .milliseconds(200)) // second timer fires
		debouncer.reset()
		debouncer.reset()                              // supersedes the third timer before it fires
		try await Task.sleep(for: .milliseconds(200))

		#expect(actionCount.value == 3)
		// Only the third timer was cancelled before firing, once, by the second reset.
		#expect(cancelCount.value == 1)
		_ = debouncer
	}
}

@Suite("Debouncer Memory Tests")
struct DebouncerMemoryTests {

	private final class Owner {
		var debouncer: Debouncer?
		init(delay: TimeInterval, action: @escaping @Sendable () -> Void = {}, weakCapture: Bool) {
			if weakCapture {
				debouncer = Debouncer(delay: delay) { [weak self] in
					_ = self
					action()
				}
			} else {
				debouncer = Debouncer(delay: delay) {
					// Strongly captures `self`, forming a retain cycle with `debouncer`.
					_ = self
					action()
				}
			}
		}
	}

	@Test("An owner captured weakly by the action is released, even after the action fired")
	func testWeakCaptureReleasesOwner() async throws {
		weak var weakOwner: Owner?
		do {
			let owner = Owner(delay: 0.02, weakCapture: true)
			weakOwner = owner
			try await Task.sleep(for: .milliseconds(150)) // let the action fire once
		}
		#expect(weakOwner == nil)
	}

	@Test("An owner captured strongly by the action is never released (documents the retain cycle)")
	func testStrongCaptureLeaksOwner() async throws {
		weak var weakOwner: Owner?
		do {
			let owner = Owner(delay: 0.02, weakCapture: false)
			weakOwner = owner
			try await Task.sleep(for: .milliseconds(150))
		}
		#expect(weakOwner != nil)
		// Break the cycle so the test itself doesn't leak.
		weakOwner?.debouncer = nil
		#expect(weakOwner == nil)
	}

	@Test("Dropping the last reference to a Debouncer before it fires means the action never runs")
	func testDroppedDebouncerNeverFires() async throws {
		let fireCount = Atomic(0)
		do {
			_ = Debouncer(delay: 0.05) { fireCount.mutate { $0 += 1 } }
		}
		try await Task.sleep(for: .milliseconds(200))
		#expect(fireCount.value == 0)
	}
}
