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

	@Test("Test Dictionary Literal and Set Limit")
	func testDictionaryLiteralAndSetLimit() async {
		var dictionary: RollingDictionary = ["A": 1, "B": 2]
		#expect(dictionary["A"] == 1)
		#expect(dictionary["B"] == 2)

		dictionary.setLimit(1)
		#expect(dictionary.getKeyLimit() == 1)
		#expect(dictionary["A"] == nil)
		#expect(dictionary["B"] != nil)
	}

	@Test("Test Dictionary Keys")
	func testDictionaryKeys() async {
		var dictionary: RollingDictionary = ["A": 1,
											 "B": 2,
											 "C": 3,
											 "D": 4]
		let keys = Array(dictionary.keys)

		#expect(keys.count == 4)

		dictionary.setLimit(2)
		#expect(dictionary["A"] == nil)
		#expect(dictionary["B"] == nil)
		#expect(dictionary["C"] == 3)
		#expect(dictionary["D"] == 4)
	}

	@Test("Default init has Int.max key limit")
	func testDefaultLimitIsIntMax() {
		let dictionary = RollingDictionary<String, Int>()
		#expect(dictionary.getKeyLimit() == Int.max)
	}

	@Test("Reading absent key returns nil")
	func testReadNonExistentKeyReturnsNil() {
		let dictionary = RollingDictionary<String, Int>()
		#expect(dictionary["missing"] == nil)
	}

	@Test("Updating an existing key changes its value without adding a duplicate key")
	func testUpdateExistingKeyDoesNotDuplicateKey() {
		var dictionary = RollingDictionary<String, Int>(limit: 3)
		dictionary["A"] = 1
		dictionary["B"] = 2
		dictionary["A"] = 99

		#expect(dictionary["A"] == 99)
		#expect(dictionary.keys.count == 2)
	}

	@Test("Assigning nil removes the value from the dictionary")
	func testSubscriptNilRemovesValue() {
		var dictionary = RollingDictionary<String, Int>(limit: 3)
		dictionary["A"] = 1
		dictionary["B"] = 2
		dictionary["A"] = nil

		#expect(dictionary["A"] == nil)
		#expect(dictionary["B"] == 2)
		#expect(dictionary.keys.count == 1)
	}

	@Test("Test Dictionary Key Count")
	func testDictionaryKeyCount() async {
		var dictionary: RollingDictionary = ["A": 1,
											 "B": 2,
											 "C": 3,
											 "D": 4]
		#expect(dictionary.keys.count == 4)

		dictionary.setLimit(2)
		#expect(dictionary.keys.count == 2)
		#expect(dictionary["C"] == 3)
		#expect(dictionary["D"] == 4)

		dictionary["E"] = 5
		dictionary["F"] = 6
		dictionary.setLimit(2)

		#expect(dictionary.keys.count == 2)
		#expect(dictionary["E"] == 5)
		#expect(dictionary["F"] == 6)
	}

	@Test("Setting limit to 0 purges all entries")
	func testLimitZeroPurgesAllEntries() {
		var dictionary: RollingDictionary = ["A": 1, "B": 2, "C": 3]
		dictionary.setLimit(0)
		#expect(dictionary.getKeyLimit() == 0)
		#expect(dictionary.keys.count == 0)
		#expect(dictionary["A"] == nil)
		#expect(dictionary["B"] == nil)
		#expect(dictionary["C"] == nil)
	}

	@Test("Inserting with limit 0 never stores values")
	func testInsertingWithLimitZero() {
		var dictionary = RollingDictionary<String, Int>(limit: 0)
		dictionary["A"] = 1
		#expect(dictionary["A"] == nil)
		#expect(dictionary.keys.count == 0)
	}

	@Test("Assigning nil to non-existent key is a no-op and does not desync state")
	func testAssigningNilToMissingKeyIsNoOp() {
		var dictionary = RollingDictionary<String, Int>(limit: 2)
		dictionary["A"] = 1
		dictionary["Ghost"] = nil
		#expect(dictionary["A"] == 1)
		#expect(dictionary.keys.count == 1)

		// Filling the dictionary then adding a new key must still purge the
		// oldest real key — a desynced internal _keys array would break this.
		dictionary["B"] = 2
		dictionary["C"] = 3
		#expect(dictionary["A"] == nil)
		#expect(dictionary["B"] == 2)
		#expect(dictionary["C"] == 3)
		#expect(dictionary.keys.count == 2)
	}

	@Test("Increasing the limit does not remove entries")
	func testIncreasingLimitKeepsAllEntries() {
		var dictionary = RollingDictionary<String, Int>(limit: 2)
		dictionary["A"] = 1
		dictionary["B"] = 2
		dictionary.setLimit(5)

		#expect(dictionary.getKeyLimit() == 5)
		#expect(dictionary["A"] == 1)
		#expect(dictionary["B"] == 2)
		#expect(dictionary.keys.count == 2)
	}

	@Test("Setting limit equal to current count keeps all entries")
	func testLimitEqualToCount() {
		var dictionary: RollingDictionary = ["A": 1, "B": 2, "C": 3]
		dictionary.setLimit(3)
		#expect(dictionary.keys.count == 3)
		#expect(dictionary["A"] == 1)
		#expect(dictionary["B"] == 2)
		#expect(dictionary["C"] == 3)
	}

	@Test("Updating an existing key does not reset its insertion ordering")
	func testUpdatingDoesNotChangeInsertionOrder() {
		var dictionary = RollingDictionary<String, Int>(limit: 3)
		dictionary["A"] = 1
		dictionary["B"] = 2
		dictionary["C"] = 3
		// Updating A's value should not move A to the back of the queue.
		dictionary["A"] = 99
		dictionary["D"] = 4

		#expect(dictionary["A"] == nil, "A should be purged since it was the oldest key when D was added")
		#expect(dictionary["B"] == 2)
		#expect(dictionary["C"] == 3)
		#expect(dictionary["D"] == 4)
	}

	@Test("Inserting many entries beyond the limit retains only the most recent")
	func testBulkInsertionBeyondLimit() {
		var dictionary = RollingDictionary<Int, String>(limit: 3)
		for i in 0..<100 {
			dictionary[i] = "value-\(i)"
		}
		#expect(dictionary.keys.count == 3)
		#expect(dictionary[97] == "value-97")
		#expect(dictionary[98] == "value-98")
		#expect(dictionary[99] == "value-99")
		#expect(dictionary[0] == nil)
		#expect(dictionary[50] == nil)
	}

	@Test("Removing all entries via nil leaves the dictionary empty and reusable")
	func testRemovingAllEntries() {
		var dictionary = RollingDictionary<String, Int>(limit: 3)
		dictionary["A"] = 1
		dictionary["B"] = 2
		dictionary["C"] = 3
		dictionary["A"] = nil
		dictionary["B"] = nil
		dictionary["C"] = nil
		#expect(dictionary.keys.count == 0)

		// New inserts should still respect the limit after a full drain.
		dictionary["X"] = 10
		dictionary["Y"] = 20
		dictionary["Z"] = 30
		dictionary["W"] = 40
		#expect(dictionary.keys.count == 3)
		#expect(dictionary["X"] == nil)
	}
}
