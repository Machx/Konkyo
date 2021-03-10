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

final class RollingDictionaryTests: XCTestCase {
	
	func testBasicRollingDictionaryWith1Value() {
		var dictionary = RollingDictionary<String,Int>(limit: 1)
		
		dictionary["Ted"] = 1
		
		XCTAssertEqual(dictionary["Ted"], 1)
		
		dictionary["Lasso"] = 2
		
		XCTAssertEqual(dictionary["Lasso"], 2)
		XCTAssertNil(dictionary["Ted"])
	}
	
	func testBasicRollingDictionaryWithMultipleValues() {
		var dictionary = RollingDictionary<String,Int>(limit: 2)
		
		dictionary["Ted"] = 1
		
		XCTAssertEqual(dictionary["Ted"], 1)
		
		dictionary["Lasso"] = 2
		
		XCTAssertEqual(dictionary["Ted"], 1)
		XCTAssertEqual(dictionary["Lasso"], 2)
		
		dictionary["Thing"] = 3
		
		XCTAssertEqual(dictionary["Lasso"], 2)
		XCTAssertEqual(dictionary["Thing"], 3)
		XCTAssertNil(dictionary["Ted"])
	}
	
	func testRollingDictionaryLimitAPI() {
		var dictionary = RollingDictionary<String,Int>(limit: 2)
		
		dictionary["Ted"] = 1
		dictionary["Lasso"] = 2
		
		XCTAssertEqual(dictionary["Ted"], 1)
		XCTAssertEqual(dictionary["Lasso"], 2)
		
		dictionary.setLimit(1)
		
		XCTAssertNil(dictionary["Ted"])
		XCTAssertEqual(dictionary["Lasso"], 2)
	}
	
	func testDictionaryLiteral() {
		let dictionary: RollingDictionary = ["A": 1, "B": 2]
		
		XCTAssertNotNil(dictionary)
		XCTAssertEqual(dictionary.getKeyLimit(), Int.max)
		XCTAssertEqual(dictionary["A"], 1)
		XCTAssertEqual(dictionary["B"], 2)
	}
	
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
		//XCTExpectFailure("Investigating Bug")
		
		var dictionary: RollingDictionary = ["A": 1,
											 "B": 2,
											 "C": 3,
											 "D": 4]
		
		let keys = Array(dictionary.keys)
		
		XCTAssertEqual(keys.count, 4)
		
		dictionary.setLimit(2)
		
		// Related to Issue #6
		//XCTAssertEqual(keys.count, 2)
	}
}
