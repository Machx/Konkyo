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


import XCTest
import Foundation
import Konkyo

final class MutexTests: XCTestCase {
	
	func testMutex() {
		let mutex = Mutex()
		var total = 0
		let iterations = Int.random(in: 15_000...20000)
		DispatchQueue.concurrentPerform(iterations: iterations) { (index) in
			mutex.lock()
			total += index + 1 // Adjust because indexes start at 0.
			mutex.unlock()
		}
		
		let expected = (iterations * (iterations + 1)) / 2
		
		XCTAssertEqual(total, expected, "Failed with Iterations: \(iterations)")
	}
	
	func testRecursiveMutex() {
		let mutex = Mutex(type: .recursive)
		let expectation = XCTestExpectation()
		
		DispatchQueue.global(qos: .background).async {
			mutex.lock()
			mutex.lock()

			expectation.fulfill()
			
			mutex.unlock()
			mutex.unlock()
		}
		
		wait(for: [expectation], timeout: 2.0)
	}
	
    static var allTests = [
        ("testMutex", testMutex),
		("testRecursiveMutex", testRecursiveMutex),
    ]
}
