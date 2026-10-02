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

import Konkyo
import Testing
import Foundation

private enum DatabaseError: Error {
	case noRecordFound
	case connectionLost
}

private enum ProfileError: Error, TraceableError {
	case noSavedProfileError(DatabaseError)

	var containedError: Error {
		switch self {
		case .noSavedProfileError(let error):
			return error
		}
	}
}

private enum AppError: Error, TraceableError {
	case loadingError(ProfileError)

	var containedError: Error {
		switch self {
		case .loadingError(let error):
			return error
		}
	}
}

private struct WrapperError: Error, TraceableError {
	let containedError: Error
}

private struct PlainStructError: Error {
	let reason: String
}

@Suite("TraceableError Tests")
struct ErrorsTests {

	@Test("Non-traceable error returns a single Type - case line")
	func testNonTraceableErrorSingleLine() async throws {
		let error = DatabaseError.noRecordFound
		#expect(error.traceableErrorDescription() == "DatabaseError - noRecordFound")
	}

	@Test("Two level chain indents the contained error once")
	func testTwoLevelChain() async throws {
		let error = ProfileError.noSavedProfileError(.noRecordFound)
		let expected = """
		ProfileError - noSavedProfileError
		└─ DatabaseError - noRecordFound
		"""
		#expect(error.traceableErrorDescription() == expected)
	}

	@Test("Three level chain matches the documented example format")
	func testThreeLevelChain() async throws {
		let error = AppError.loadingError(.noSavedProfileError(.noRecordFound))
		let expected = """
		AppError - loadingError
		└─ ProfileError - noSavedProfileError
		   └─ DatabaseError - noRecordFound
		"""
		#expect(error.traceableErrorDescription() == expected)
	}

	@Test("Different leaf case names are reflected in the description")
	func testDifferentLeafCase() async throws {
		let error = AppError.loadingError(.noSavedProfileError(.connectionLost))
		let expected = """
		AppError - loadingError
		└─ ProfileError - noSavedProfileError
		   └─ DatabaseError - connectionLost
		"""
		#expect(error.traceableErrorDescription() == expected)
	}

	@Test("Struct conforming to TraceableError still recurses correctly")
	func testStructTraceableError() async throws {
		let error = WrapperError(containedError: DatabaseError.noRecordFound)
		let lines = error.traceableErrorDescription().components(separatedBy: "\n")

		// The struct's own description is whatever String(describing:) produces
		// for it, so only assert on the parts this API controls: the type name
		// prefix on the first line, and the fully-formed leaf line.
		#expect(lines.count == 2)
		#expect(lines[0].hasPrefix("WrapperError - "))
		#expect(lines[1] == "└─ DatabaseError - noRecordFound")
	}

	@Test("Non-enum leaf error falls back to its full description")
	func testNonEnumLeafErrorDescription() async throws {
		let error = PlainStructError(reason: "disk full")
		let description = error.traceableErrorDescription()
		#expect(description.hasPrefix("PlainStructError - "))
		#expect(description.contains("disk full"))
	}

	@Test("Plain NSError with no underlying error is a single line")
	func testPlainNSErrorSingleLine() async throws {
		let error = NSError(domain: "com.konkyo.test", code: 42, userInfo: [:])
		#expect(error.traceableErrorDescription() == "NSError - com.konkyo.test (42)")
	}

	@Test("NSError recurses into its NSUnderlyingErrorKey error")
	func testNSErrorUnderlyingErrorKey() async throws {
		let underlying = NSError(domain: "com.konkyo.test.underlying", code: 7, userInfo: [:])
		let error = NSError(
			domain: "com.konkyo.test",
			code: 42,
			userInfo: [NSUnderlyingErrorKey: underlying]
		)
		let expected = """
		NSError - com.konkyo.test (42)
		└─ NSError - com.konkyo.test.underlying (7)
		"""
		#expect(error.traceableErrorDescription() == expected)
	}

	@Test("NSError recurses through multiple underlyingErrors levels")
	func testNSErrorMultipleUnderlyingErrorsLevels() async throws {
		let root = NSError(domain: "com.konkyo.test.root", code: 1, userInfo: [:])
		let middle = NSError(
			domain: "com.konkyo.test.middle",
			code: 2,
			userInfo: [NSUnderlyingErrorKey: root]
		)
		let top = NSError(
			domain: "com.konkyo.test.top",
			code: 3,
			userInfo: [NSUnderlyingErrorKey: middle]
		)
		let expected = """
		NSError - com.konkyo.test.top (3)
		└─ NSError - com.konkyo.test.middle (2)
		   └─ NSError - com.konkyo.test.root (1)
		"""
		#expect(top.traceableErrorDescription() == expected)
	}

}
