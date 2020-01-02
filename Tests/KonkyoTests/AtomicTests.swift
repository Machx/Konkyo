///
/// Copyright 2019 Colin Wheeler
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
@testable import Konkyo

@available(OSX 10.12, *)
final class AtomicTests: XCTestCase {
	
	func testAtomic() {
		let numbers = Atomic<[Int]>([])
		let queue = DispatchQueue(label: "com.konkyo.unittests", attributes: [.concurrent])
		let group = DispatchGroup()
		
		for i in 1...10000 {
			queue.async(group:group) {
				numbers.mutate { (numbers) in
					numbers.append(i)
				}
			}
		}
		
		group.wait()
		
		XCTAssertEqual(numbers.value.count, 10000)
		
		let totalValue = numbers.value.reduce(0, +)
		XCTAssertEqual(totalValue, 50005000)
	}
	
	static var allTests = [
		("testAtomic", testAtomic),
    ]
}
