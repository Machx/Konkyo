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

final class CWConditionTests: XCTestCase {
	
	func testCWCondition() {
		let condition = Condition()
		let expectation = XCTestExpectation()
		
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3) {
			condition.signal()
		}
		
		condition.wait()
		expectation.fulfill()
	}
	
	func testNegativeCondition() {
		let condition = Condition()
		let expectation = XCTestExpectation()
		expectation.isInverted = true
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.10) {
			condition.wait()
			expectation.fulfill()
		}
		wait(for: [expectation], timeout: 2.0)
	}
	
	func testWaitUntilDate() {
		let condition = Condition()
		let expectaction = XCTestExpectation()
		expectaction.isInverted = true
		
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
			condition.signal()
			expectaction.fulfill()
		}
		
		let result = condition.wait(until: Date(timeIntervalSinceNow: 3.0))
		XCTAssertTrue(result)
	}

	func testWaitUntilDate2() {
		
	}
	
	func testWaitUntilDateNegative() {
		let condition = Condition()
		
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0) {
			condition.signal()
		}
		
		let result = condition.wait(until: Date())
		XCTAssertFalse(result)
	}
}
