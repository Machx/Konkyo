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

@Suite("CWCondition Tests")
struct CWConditionTests {
	
	@Test("Test Condition")
	func testCWCondition() async {
		/// This isn't ideal, but within the context of Swift Tests this is as good as
		/// can reasonably be expected. PThread API's don't seem to play well with the
		/// async await contexts, so in lieu of trying hacks upon hacks trying to make
		/// it all work I have this test which really isn't a test, but if this unit
		/// test gets hung not running properly its the only way to really know if its
		/// not working.
		nonisolated(unsafe) let condition = Condition()

		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
			condition.signal()
		}

		condition.wait()
	}

	@Test("Test wait until date")
	func testWaitUntilDate() async throws {
		await Task { @MainActor in
			nonisolated(unsafe) let condition = Condition()

			DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
				condition.signal()
			}

			let result = condition.wait(until: Date(timeIntervalSinceNow: 3.0))
			await withCheckedContinuation { continuation in
				RunLoop.main.run(mode: .default, before: .now + 1.0)
				continuation.resume()
			}
			#expect(result == true)
		}
	}

	@Test("Test Wait Until with Negative Date")
	func testWaitUntilDateNegative() throws {
		nonisolated(unsafe) let condition = Condition()

		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
			condition.signal()
		}

		// Give it a date way in the past so it should reject it
		let result = condition.wait(until: Date(timeIntervalSince1970: 6))
		#expect(result == false)
	}

	@Test("Test wait until now")
	func testWaitUntilDateNegative2() throws {
		nonisolated(unsafe) let condition = Condition()

		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0) {
			condition.signal()
		}

		let result = condition.wait(until: Date())
		#expect(result == false)
	}
}

