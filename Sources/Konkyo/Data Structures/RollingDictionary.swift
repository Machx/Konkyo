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

import Foundation

public struct RollingDictionary<Key:Hashable,Value> {
	var _keys: Array<Key>
	var _dictionary: Dictionary<Key,Value>
	var _limit: Int
	
	public init(limit keyLimit: Int) {
		_keys = [Key]()
		_dictionary = [Key: Value]()
		_limit = keyLimit
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
			if _keys.count == _limit {
				_dictionary.removeValue(forKey: _keys[0])
			}
		}
	}
	
	public var keys: Dictionary<Key, Value>.Keys {
		return _dictionary.keys
	}
}
