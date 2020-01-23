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
@testable import Konkyo

class MyClass {
	var myNum = 0
	
	init() {
		myNum = 0
	}
}

@available(OSX 10.12, *)
final class KonkyoTests: XCTestCase {
	
    func testVersion() {
		let version = Konkyo.Version()
		XCTAssertEqual(version.major, 0)
		XCTAssertEqual(version.minor, 1)
		XCTAssertEqual(version.bugfix, 0)
    }
	
	func testCreationOperator() {
		let thing = MyClass() <- {
			$0.myNum = 5
		}
		
		XCTAssertEqual(thing.myNum, 5)
	}
	
    static var allTests = [
        ("testVersion", testVersion),
		("testCreationOperator", testCreationOperator)
    ]
}
