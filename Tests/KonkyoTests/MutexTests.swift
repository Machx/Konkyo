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
		let iterations = Int.random(in: 5000...15000)
		print("TEST MUTEX with \(iterations) iterations")
		DispatchQueue.concurrentPerform(iterations: iterations) { (index) in
			mutex.lock()
			total += index + 1 // Because Indexes start at 0 so we adjust...
			mutex.unlock()
		}
		
		let expected = (iterations / 2) * (iterations + 1)
		
		XCTAssertEqual(total, expected)
	}
	
	
    static var allTests = [
        ("testMutex", testMutex),
    ]
}
