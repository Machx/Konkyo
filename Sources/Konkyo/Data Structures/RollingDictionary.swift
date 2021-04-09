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

/// Rolling Dictionary is a Dictionary intended to only hold a rolling buffer of the last n keys set.
///
/// Rolling Dictionary is a Dictionary that is intended to hold a limited number of
/// records compared to Dictionary. You can use it like a regular dictionary by default
/// the max number of keys is Int.max. However if you set it to any other number it will
/// check to make sure it only has <= the limit of keys its been set to store. If it has
/// more then it will delete key value pairs by using the key ordering from oldest to
/// yongest until it has limit number of key/value pairs.
public struct RollingDictionary<Key:Hashable,Value>:ExpressibleByDictionaryLiteral {
	// Array of keys stored to preserve the ordering.
	private var _keys: Array<Key>
	// Rolling Dictionary wraps around Dictionary providing additional functionality.
	private var _dictionary: Dictionary<Key,Value>
	// The max amount of Keys that an instance should store.
	private var _limit: Int
	
	init() {
		_keys = [Key]()
		_dictionary = [Key: Value]()
		_limit = Int.max
	}
	
	/// Initializes a Rolling Dictionary with a specified Key limit.
	/// - Parameter keyLimit: The maximum number of key/value pairs to configure the rolling dictionary with.
	public init(limit keyLimit: Int) {
		_keys = [Key]()
		_dictionary = [Key: Value]()
		_limit = keyLimit
	}
	
	/// Initializes a Rolling Dictionary with a dictionary literal and Int.max Maximum number of key/value pairs.
	///
	/// - Parameter elements: The Dictionary literal for key/value pairs to initialize the structure with.
	public init(dictionaryLiteral elements: (Key, Value)...) {
		_limit = Int.max
		// do it this way to preserve ordering
		_dictionary = Dictionary<Key,Value>()
		_keys = [Key]()
		for (key,value) in elements {
			_dictionary[key] = value
			_keys.append(key)
		}
	}
	
	public subscript(key: Key) -> Value? {
		get {
			_dictionary[key]
		}
		set(newValue) {
			guard let newValue = newValue else {
				self._dictionary.removeValue(forKey: key)
				return
			}
			let oldValue = self._dictionary.updateValue(newValue, forKey: key)
			if oldValue == nil {
				self._keys.append(key)
			}
			filterExcessEntries()
		}
	}
	
	/// Returns a collection of just the keys in the dictionary
	public var keys: Dictionary<Key, Value>.Keys { _dictionary.keys }
	
	/// Returns the maximum number of keys allowed in the Rolling Dictionary
	///
	/// If a Rolling Dictionary isn't configured with a limit the maximum number of key/value pairs is Int.max.
	/// - Returns: A Int representing the maximum number of allowed key/value pairs in the dictionary.
	public func getKeyLimit() -> Int { _limit }
	
	/// Sets the maximum number of key/value pairs allowed in the dictionary
	///
	/// When setting this the dictionary records the maximum allowed number of
	/// key/value pairs and then purges excess key/value pairs if the count is
	/// greater than the given maximum.
	/// - Parameter maxKeysCount: The intended maximum allowed number of key value pairs for the dictionary.
	public mutating func setLimit(_ maxKeysCount: Int) {
		_limit = maxKeysCount
		filterExcessEntries()
	}
	
	private mutating func filterExcessEntries() {
		while _keys.count > _limit {
			if let value = _dictionary.removeValue(forKey: _keys[0]) {
				//FIXME: Remove when Swift gets the ability to specify macOS 11 in Package.swift
				print("Removing Key/value pair (\(_keys[0]), \(value)")
				_keys.remove(at: 0)
			}
		}
	}
}
