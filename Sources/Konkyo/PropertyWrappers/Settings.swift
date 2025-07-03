///
/// Copyright 2024 Colin Wheeler
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

public protocol UserDefaultsProtocol {
	func object(forKey defaultName: String) -> Any?
	func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol {}

/// Property wrapper that focuses on Access to the UserDefaults values.
@propertyWrapper public struct Preferences<Value: Codable> {
	public let key: String
	public let defaultValue: Value
	private let userDefaults: UserDefaultsProtocol

	public init(key: String, defaultValue: Value, userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
		self.key = key
		self.defaultValue = defaultValue
		self.userDefaults = userDefaults
	}

	public var wrappedValue: Value {
		get { UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue }
		set { UserDefaults.standard.setValue(newValue, forKey: key) }
	}
}
