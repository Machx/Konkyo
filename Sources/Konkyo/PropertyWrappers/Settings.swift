//
//  File.swift
//  
//
//  Created by Colin Wheeler on 4/12/24.
//

import Foundation

@propertyWrapper public struct Preferences<Value: Codable> {
	public let key: String
	public let defaultValue: Value

	public init(key: String, defaultValue: Value) {
		self.key = key
		self.defaultValue = defaultValue
	}

	public var wrappedValue: Value {
		get { UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue }
		set { UserDefaults.standard.setValue(newValue, forKey: key) }
	}
}
