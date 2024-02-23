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

public final class DebouncerTests: XCTestCase {

	func testDebouncer() {
		let expectation = XCTestExpectation()
		expectation.assertForOverFulfill = true
		let bouncer = Debouncer(delay: 1.0) {
			print("Hello")
			expectation.fulfill()
		}
		for _ in 0...1000 {
			bouncer.reset()
		}
		wait(for: [expectation], timeout: 5.0)
		bouncer.cancel()
	}

	func testRepeatingDebouncer() {
		let expectation = XCTestExpectation()
		expectation.expectedFulfillmentCount = 2
		var count = 0
		let bouncer = Debouncer(oneShot: false, delay: 1.0, queue: .main) { [weak self] in
			guard let self else { return }
			count += 1
			expectation.fulfill()
		}
		wait(for: [expectation], timeout: 3.0)
		bouncer.cancel()
	}

	func testCancelAfter() {
		let expectation = XCTestExpectation()
		expectation.expectedFulfillmentCount = 2
		expectation.assertForOverFulfill = true
		let bouncer = Debouncer(oneShot: false, cancelAfter: 2, delay: 1.0, queue: .main) { [weak self] in
			guard self != nil else { return }
			expectation.fulfill()
		}
		wait(for: [expectation], timeout: 4.0)
		bouncer.cancel()
	}
}
