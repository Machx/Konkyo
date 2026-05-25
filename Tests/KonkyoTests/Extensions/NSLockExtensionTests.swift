///
/// Copyright 2025 Colin Wheeler
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

import Testing
import Konkyo
import Foundation

@Suite("NSLock Extension Tests")
struct NSLockExtensionTest {

	@Test("tryLock executes block when lock is available")
	func nslockExtensionTest() async throws {
		let lock = NSLock()
		await confirmation(expectedCount: 1) { confirmation in
			lock.tryLock {
				confirmation.confirm()
			}
		}
	}

	@Test("tryLock does not execute block when lock is already held")
	func testTryLockDoesNotExecuteWhenAlreadyLocked() {
		let lock = NSLock()
		lock.lock()

		nonisolated(unsafe) var blockExecuted = false
		DispatchQueue.global().sync {
			lock.tryLock {
				blockExecuted = true
			}
		}

		lock.unlock()
		#expect(blockExecuted == false)
	}

	@Test("lock is released after tryLock so subsequent tryLock succeeds")
	func testLockIsReleasedAfterTryLock() async {
		let lock = NSLock()

		await confirmation("First tryLock executes", expectedCount: 1) { first in
			lock.tryLock { first() }
		}

		// Lock must have been released; a second attempt should also succeed.
		await confirmation("Second tryLock executes", expectedCount: 1) { second in
			lock.tryLock { second() }
		}
	}
}
