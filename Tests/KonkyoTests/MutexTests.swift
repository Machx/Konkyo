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

@Test("Test Mutex")
func testMutex() {
	let mutex = Mutex()
	nonisolated(unsafe) var total = 0
	let iterations = Int.random(in: 15_000...20_000)
	DispatchQueue.concurrentPerform(iterations: iterations) { (index) in
		mutex.lock()
		total += index + 1 // Adjust because indexes start at 0.
		mutex.unlock()
	}

	let expected = (iterations * (iterations + 1)) / 2
	#expect(total == expected)
}

@Test("Test Recursive Mutex")
func testRecursiveMutex() async {
	await confirmation(expectedCount: 1) { confirm in
		let mutex = Mutex(type: .recursive)

		DispatchQueue.global(qos: .background).sync {
			mutex.lock()
			mutex.lock()

			confirm()

			mutex.unlock()
			mutex.unlock()
		}
	}
}
