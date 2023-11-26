///
/// Copyright 2023 Colin Wheeler
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

/// Test a closure for something that should throw an error, and assert if nothing does.
///
/// If the closure throws an error the assertion passes, but if nothing throws an error,
/// then this calls XCTFail passing in the location it was called to indicate that
/// nothing in the closure threw an error.
///
/// - Parameters:
///   - file: The file where the failure has occurred.
///   - line: The line in file where the failure occurred.
///   - block: A closure in which you can test for an error to be thrown.
public func XCTExpectError(_ file: StaticString = #file,
						   _ line: UInt = #line,
						   _ block: () throws -> Void) {
	var errorThrown: Bool = false
	do {
		try block()
	} catch {
		errorThrown = true
	}
	guard errorThrown == false else { return }
	XCTFail("Expected Error to be thrown in block but no error was thrown.\(file):\(line)",
			file: file,
			line: line)
}
