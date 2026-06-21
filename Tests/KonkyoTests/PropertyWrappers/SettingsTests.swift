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

import Foundation
import Konkyo
import Testing

@Suite("Preferences Property Wrapper Tests")
struct SettingsTests {

	// MARK: - Helpers

	final class MockUserDefaults: UserDefaultsProtocol {
		private var storage: [String: Any] = [:]

		func object(forKey defaultName: String) -> Any? {
			storage[defaultName]
		}

		func set(_ value: Any?, forKey defaultName: String) {
			storage[defaultName] = value
		}
	}

	// MARK: - Primitive Types

	@Test("Stores and retrieves Int correctly")
	func testIntRoundTrip() {
		let mock = MockUserDefaults()
		var prefs = Preferences(key: "count", defaultValue: 0, userDefaults: mock)
		prefs.wrappedValue = 42
		#expect(prefs.wrappedValue == 42)
	}

	@Test("Stores and retrieves String correctly")
	func testStringRoundTrip() {
		let mock = MockUserDefaults()
		var prefs = Preferences(key: "name", defaultValue: "", userDefaults: mock)
		prefs.wrappedValue = "hello"
		#expect(prefs.wrappedValue == "hello")
	}

	@Test("Stores and retrieves Bool correctly")
	func testBoolRoundTrip() {
		let mock = MockUserDefaults()
		var prefs = Preferences(key: "enabled", defaultValue: false, userDefaults: mock)
		prefs.wrappedValue = true
		#expect(prefs.wrappedValue == true)
	}

	// MARK: - Default Values

	@Test("Returns default value when key is absent")
	func testReturnsDefaultForMissingKey() {
		let mock = MockUserDefaults()
		let prefs = Preferences(key: "missing", defaultValue: 99, userDefaults: mock)
		#expect(prefs.wrappedValue == 99)
	}

	@Test("Returns default Codable struct when key is absent")
	func testReturnsDefaultCodableStructForMissingKey() {
		struct UserProfile: Codable, Equatable {
			let name: String
			let age: Int
		}

		let mock = MockUserDefaults()
		let defaultProfile = UserProfile(name: "Default", age: 0)
		let prefs = Preferences(key: "profile", defaultValue: defaultProfile, userDefaults: mock)
		#expect(prefs.wrappedValue == defaultProfile)
	}

	// MARK: - Complex Codable Types

	@Test("Stores and retrieves a Codable struct correctly")
	func testCodableStructRoundTrip() {
		struct UserProfile: Codable, Equatable {
			let name: String
			let age: Int
		}

		let mock = MockUserDefaults()
		var prefs = Preferences(
			key: "profile",
			defaultValue: UserProfile(name: "Default", age: 0),
			userDefaults: mock
		)
		let profile = UserProfile(name: "Alice", age: 30)
		prefs.wrappedValue = profile
		#expect(prefs.wrappedValue == profile)
	}

	@Test("Stores and retrieves a Codable enum correctly")
	func testCodableEnumRoundTrip() {
		enum Theme: String, Codable, Equatable {
			case light, dark, system
		}

		let mock = MockUserDefaults()
		var prefs = Preferences(key: "theme", defaultValue: Theme.system, userDefaults: mock)
		prefs.wrappedValue = .dark
		#expect(prefs.wrappedValue == .dark)
	}

	@Test("Stores and retrieves an array of Codable values correctly")
	func testCodableArrayRoundTrip() {
		let mock = MockUserDefaults()
		var prefs = Preferences(key: "tags", defaultValue: [String](), userDefaults: mock)
		prefs.wrappedValue = ["swift", "ios", "apple"]
		#expect(prefs.wrappedValue == ["swift", "ios", "apple"])
	}

	// MARK: - Persistence Encoding

	@Test("Value is persisted as Data in the underlying store")
	func testValueStoredAsData() {
		let mock = MockUserDefaults()
		var prefs = Preferences(key: "value", defaultValue: 0, userDefaults: mock)
		prefs.wrappedValue = 7
		#expect(mock.object(forKey: "value") is Data)
	}

	// MARK: - Edge cases

	@Test("Non-Data value in storage falls back to default")
	func testNonDataStoredValueFallsBackToDefault() {
		let mock = MockUserDefaults()
		// Simulate a legacy entry that was written as a String (not Data).
		mock.set("not-encoded", forKey: "legacy")
		let prefs = Preferences(key: "legacy", defaultValue: 42, userDefaults: mock)
		#expect(prefs.wrappedValue == 42)
	}

	@Test("Corrupt Data in storage falls back to default")
	func testCorruptDataFallsBackToDefault() {
		let mock = MockUserDefaults()
		// Random bytes that cannot decode as an Int.
		mock.set(Data([0xFF, 0x00, 0x42, 0xAB]), forKey: "corrupt")
		let prefs = Preferences(key: "corrupt", defaultValue: 99, userDefaults: mock)
		#expect(prefs.wrappedValue == 99)
	}

	@Test("Data encoded for a different type falls back to default")
	func testWrongTypeDataFallsBackToDefault() throws {
		let mock = MockUserDefaults()
		let encoded = try JSONEncoder().encode(["a", "b", "c"])
		mock.set(encoded, forKey: "mismatched")
		let prefs = Preferences(key: "mismatched", defaultValue: 0, userDefaults: mock)
		#expect(prefs.wrappedValue == 0)
	}

	@Test("Updating wrappedValue overwrites the previous value")
	func testWrappedValueOverwrites() {
		let mock = MockUserDefaults()
		var prefs = Preferences(key: "counter", defaultValue: 0, userDefaults: mock)
		prefs.wrappedValue = 1
		prefs.wrappedValue = 2
		prefs.wrappedValue = 3
		#expect(prefs.wrappedValue == 3)
	}

	@Test("Multiple Preferences instances over the same key share storage")
	func testMultipleInstancesShareStorage() {
		let mock = MockUserDefaults()
		var writer = Preferences(key: "shared", defaultValue: 0, userDefaults: mock)
		writer.wrappedValue = 7

		let reader = Preferences(key: "shared", defaultValue: -1, userDefaults: mock)
		#expect(reader.wrappedValue == 7)
	}

	@Test("Preferences for unrelated keys do not interfere")
	func testKeysAreNotShared() {
		let mock = MockUserDefaults()
		var a = Preferences(key: "A", defaultValue: 0, userDefaults: mock)
		var b = Preferences(key: "B", defaultValue: 0, userDefaults: mock)
		a.wrappedValue = 11
		b.wrappedValue = 22
		#expect(a.wrappedValue == 11)
		#expect(b.wrappedValue == 22)
	}

}
