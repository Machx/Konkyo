///
/// Copyright 2026 Colin Wheeler
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
import Foundation

struct ResultTests {

    @Test func testFailureError() async throws {
        func getResult() -> Result<Int,Error> {
			return .failure(NSError(domain: "Test", code: 1, userInfo: [:]))
		}

		let result = getResult()
		guard case .success(let success) = result else {
			let failureError = try #require(result.failureError)
			#expect((failureError as NSError).domain == "Test")
			return
		}
		// If we got here there is an issue
		Issue.record(NSError(domain: "com.Konkyo.ResultExtension", code: 1, userInfo: [:]))
    }

	@Test func testSuccessReturnsNilForFailureError() async throws {
		func getResult() -> Result<Int, Error> {
			return .success(42)
		}
		
		let result = getResult()
		#expect(result.failureError == nil, "Success case should return nil for failureError")
	}

	@Test func testFailureErrorWithCustomError() async throws {
		enum CustomError: Error {
			case notFound
			case invalidInput
		}
		
		func getResult() -> Result<String, CustomError> {
			return .failure(.notFound)
		}
		
		let result = getResult()
		let error = try #require(result.failureError)
		#expect(error == .notFound)
	}

	@Test func testFailureErrorPreservesErrorType() async throws {
		struct DetailedError: Error, Equatable {
			let code: Int
			let message: String
		}
		
		let expectedError = DetailedError(code: 404, message: "Not Found")
		let result: Result<String, DetailedError> = .failure(expectedError)
		
		let error = try #require(result.failureError)
		#expect(error == expectedError, "Error details should be preserved")
	}

}
