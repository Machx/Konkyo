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

final class UnfairLockTests: XCTestCase {
	
	func testUnfairLock() {
		/// Test manual lock and unlock of UnfairLock (os_unfair_lock)
		/// Using concurrent perform blocks forcing lots of contention on the lock
		let lock = UnfairLock()
		var total = 0
		let iterations = Int.random(in: 5000...15000)
		DispatchQueue.concurrentPerform(iterations: iterations) { (index) in
			lock.lock()
			total += index + 1 // Adjust because indexes start at 0.
			lock.unlock()
		}
		
		let expected = (iterations * (iterations + 1)) / 2
		XCTAssertEqual(total, expected, "Failed with Iterations: \(iterations)")
	}

	func testUnfairLockWithLock() {
		/// Same as `testUnfairLock` but using the `withLock{}` api
		let lock = UnfairLock()
		var total = 0
		let iterations = Int.random(in: 5000...15000)
		DispatchQueue.concurrentPerform(iterations: iterations) { (index) in
			lock.withLock {
				total += index + 1 // Adjust because indexes start at 0.
			}
		}

		let expected = (iterations * (iterations + 1)) / 2
		XCTAssertEqual(total, expected, "Failed with Iterations: \(iterations)")
	}

	func testUnfairLockWithLockIfAvailable() {
		/// Same as `testUnfairLockWithLock` but using `withLockIfAvailable{}`
		let lock = UnfairLock()

		var total = 0
		let iterations = Int.random(in: 5000...10000)
		DispatchQueue.concurrentPerform(iterations: iterations) { index in
			lock.withLockIfAvailable {
				total += 1
			}
		}

		XCTAssertNotEqual(total, 0)
		XCTAssertNotEqual(total, iterations)
		XCTAssertTrue(total > 0)
	}

	func testUnfairLockWithLockIfAvailable2() {
		/// Manual locking and unlocking to make sure
		/// `withLockIfAvailable {}` responds as expected
		let lock = UnfairLock()
		var total = 0

		lock.withLockIfAvailable {
			total += 1
		}
		XCTAssertEqual(total, 1)

		lock.lock()
		lock.withLockIfAvailable {
			total += 100
		}
		XCTAssertEqual(total, 1)
		lock.unlock()
	}

	func testTryLock() {
		/// Manual locking and unlock to make sure
		/// `tryLock` responds as expected
		let lock = UnfairLock()

		XCTAssertTrue(lock.tryLock())
		lock.unlock()

		lock.lock()
		XCTAssertFalse(lock.tryLock())
		lock.unlock()
	}
}
