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

import XCTest
import Konkyo
import Testing

@Test("Test basic debouncer API")
func testDebouncer() async throws {
	await confirmation("Confirm debouncedSignal is never called",
					   expectedCount: 0) { debouncedSignal in
		let bouncer = Debouncer(delay: 1.0) {
			print("Hello")
			debouncedSignal()
		}
		for _ in 0...1000 {
			bouncer.reset()
		}
		bouncer.cancel()
	}
}

@Test("Test cancel action in Debouncer")
func testCancelAction() async throws {
	try await confirmation(expectedCount: 1) { confirmCancel in
		let bouncer = Debouncer(delay: 0.5) {
			print("Hello")
		} cancelAction: {
			confirmCancel()
		}
		bouncer.cancel()
		// give cancel action a tiny bit of time so that it can be triggered...
		try await Task.sleep(for: .milliseconds(500))
	}
}

public final class DebouncerTests: XCTestCase {

	func testMultipleCancels() {
		let expectation = XCTestExpectation()
		expectation.expectedFulfillmentCount = 3
		let bouncer = Debouncer(delay: 0.5) {
			print("Hello")
		} cancelAction: {
			expectation.fulfill()
		}
		bouncer.reset()
		bouncer.reset()
		bouncer.reset()
		wait(for: [expectation], timeout: 3.0)
	}

	func testResetAfterCancel() {
		let eventExpectation = XCTestExpectation()
		let cancelExpectation = XCTestExpectation()
		let bouncer = Debouncer(delay: 0.5) {
			eventExpectation.fulfill()
		} cancelAction: {
			cancelExpectation.fulfill()
		}
		// Test Cancellation
		bouncer.cancel()
		wait(for: [cancelExpectation], timeout: 0.5)
		// Check if event block executes after cancellation
		bouncer.reset()
		wait(for: [eventExpectation], timeout: 1.0)
	}
}
