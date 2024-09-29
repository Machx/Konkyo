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
import XCTest
import Konkyo
import Testing

@Test("Test Condition")
func testCWCondition() async throws {
	let condition = Condition()

	await withCheckedContinuation { continuation in
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3) {
			condition.signal()
			continuation.resume()
		}
	}

	condition.wait()
	// FIXME: need to find better way to update this test for async & swift test
}

@Test("Test Negative Condition")
func testNegativeCondition() async throws {
	let condition = Condition()

	DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.10) {
		condition.wait()
		//expectation.fulfill()
	}

	// FIXME: re-evaluate this test and better way to implement it
	//wait(for: [expectation], timeout: 2.0)
}

@Test("Test wait until date")
func testWaitUntilDate() async throws {
	let condition = Condition()

	DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
		condition.signal()
	}

	let result = condition.wait(until: Date(timeIntervalSinceNow: 3.0))
	#expect(result == true)
}

@Test("Test Wait Until with Negative Date")
func testWaitUntilDateNegative() {
	let condition = Condition()

	DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
		condition.signal()
	}

	// Give it a date way in the past so it should reject it
	let result = condition.wait(until: Date(timeIntervalSince1970: 6))
	#expect(result == false)
}

func testWaitUntilDateNegative2() {
	let condition = Condition()

	DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0) {
		condition.signal()
	}

	let result = condition.wait(until: Date())
	XCTAssertFalse(result)
}
