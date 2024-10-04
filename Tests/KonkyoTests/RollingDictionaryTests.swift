///
/// Copyright 2021 Colin Wheeler
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
import Testing

@Suite("Rolling Dictionary Tests")
struct RollingDictionaryTests {

	@Test("Test Rolling Dictionary with 1 Value")
	func testBasicRollingDictionaryWith1Value() async {
		var dictionary = RollingDictionary<String,Int>(limit: 1)

		dictionary["Ted"] = 1
		#expect(dictionary["Ted"] == 1)

		dictionary["Lasso"] = 2
		#expect(dictionary["Lasso"] == 2)
		#expect(dictionary["Ted"] == nil)
	}

	@Test("Test Rolling Dictionary with Multiple Values")
	func testBasicRollingDictionaryWithMultipleValues() async {
		var dictionary = RollingDictionary<String,Int>(limit: 2)

		dictionary["Ted"] = 1
		#expect(dictionary["Ted"] == 1)

		dictionary["Lasso"] = 2
		#expect(dictionary["Ted"] == 1)
		#expect(dictionary["Lasso"] == 2)

		dictionary["Thing"] = 3
		#expect(dictionary["Lasso"] == 2)
		#expect(dictionary["Thing"] == 3)
		#expect(dictionary["Ted"] == nil)
	}

	@Test("Test Rolling Dictionary with Limit API")
	func testRollingDictionaryLimitAPI() async {
		var dictionary = RollingDictionary<String,Int>(limit: 2)
		dictionary["Ted"] = 1
		dictionary["Lasso"] = 2

		#expect(dictionary["Ted"] == 1)
		#expect(dictionary["Lasso"] == 2)

		dictionary.setLimit(1)
		#expect(dictionary["Ted"] == nil)
		#expect(dictionary["Lasso"] == 2)
	}

	@Test("Test Rolling Dictionary with Dictionary Literal")
	func testDictionaryLiteral() async {
		let dictionary: RollingDictionary = ["A": 1, "B": 2]

		#expect(dictionary != nil)
		#expect(dictionary.getKeyLimit() == Int.max)
		#expect(dictionary["A"] == 1)
		#expect(dictionary["B"] == 2)
	}
}

//final class RollingDictionaryTests: XCTestCase {
	
	func testDictionaryLiteralAndSetLimit() {
		var dictionary: RollingDictionary = ["A": 1, "B": 2]
		
		XCTAssertNotNil(dictionary)
		XCTAssertEqual(dictionary["A"], 1)
		XCTAssertEqual(dictionary["B"], 2)
		
		dictionary.setLimit(1)
		
		XCTAssertEqual(dictionary.getKeyLimit(), 1)
		XCTAssertNil(dictionary["A"])
		XCTAssertNotNil(dictionary["B"])
	}
	
	func testDictionaryKeys() {
		var dictionary: RollingDictionary = ["A": 1,
											 "B": 2,
											 "C": 3,
											 "D": 4]
		
		let keys = Array(dictionary.keys)
		
		XCTAssertEqual(keys.count, 4)
		
		dictionary.setLimit(2)
		
		XCTAssertNil(dictionary["A"])
		XCTAssertNil(dictionary["B"])
		XCTAssertEqual(dictionary["C"], 3)
		XCTAssertEqual(dictionary["D"], 4)
	}
	
	func testDictionaryKeyCount() {
		var dictionary: RollingDictionary = ["A": 1,
											 "B": 2,
											 "C": 3,
											 "D": 4]
		
		XCTAssertEqual(dictionary.keys.count, 4)
		
		dictionary.setLimit(2)
		
		XCTAssertEqual(dictionary.keys.count, 2)
		XCTAssertEqual(dictionary["C"], 3)
		XCTAssertEqual(dictionary["D"], 4)
		
		dictionary["E"] = 5
		dictionary["F"] = 6
		
		dictionary.setLimit(2)
		
		XCTAssertEqual(dictionary.keys.count, 2)
		XCTAssertEqual(dictionary["E"], 5)
		XCTAssertEqual(dictionary["F"], 6)
	}
//}
