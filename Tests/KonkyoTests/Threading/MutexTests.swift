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

@Suite
struct MutexTests {
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

	@Test
	func tryLockTest() {
		let mutex = Mutex()
		#expect(mutex.tryLock() == true)
		#expect(mutex.tryLock() == false)
		mutex.unlock()
	}

	@Test("withLock executes the block")
	func testWithLockExecutesBlock() async {
		let mutex = Mutex()
		await confirmation(expectedCount: 1) { confirm in
			mutex.withLock {
				confirm()
			}
		}
	}

	@Test("withLock releases the lock after the block completes")
	func testWithLockReleasesLockAfterBlock() {
		let mutex = Mutex()
		mutex.withLock { }
		// If the lock was not released, this tryLock would fail.
		#expect(mutex.tryLock() == true)
		mutex.unlock()
	}

	@Test("tryLock(block:) executes block when lock is available")
	func testTryLockBlockExecutesWhenAvailable() async {
		let mutex = Mutex()
		await confirmation(expectedCount: 1) { confirm in
			mutex.tryLock {
				confirm()
			}
		}
	}

	@Test("tryLock(block:) does not execute block when already locked")
	func testTryLockBlockSkipsWhenAlreadyLocked() {
		let mutex = Mutex()
		mutex.lock()

		nonisolated(unsafe) var executed = false
		DispatchQueue.global().sync {
			mutex.tryLock {
				executed = true
			}
		}
		mutex.unlock()
		#expect(executed == false)
	}

	@Test("tryLock(block:) releases the lock after execution so a subsequent tryLock succeeds")
	func testTryLockBlockReleasesLock() {
		let mutex = Mutex()
		mutex.tryLock { }
		#expect(mutex.tryLock() == true)
		mutex.unlock()
	}

	@Test("Recursive mutex can be locked multiple times on the same thread without deadlock")
	func testRecursiveMutexAllowsMultipleLocksFromSameThread() {
		let mutex = Mutex(type: .recursive)
		mutex.lock()
		// A non-recursive mutex would fail here.
		#expect(mutex.tryLock() == true)
		mutex.unlock()
		mutex.unlock()
	}

	@Test("tryLock succeeds after unlock")
	func testTryLockAvailableAfterUnlock() {
		let mutex = Mutex()
		mutex.lock()
		mutex.unlock()
		#expect(mutex.tryLock() == true)
		mutex.unlock()
	}
}

