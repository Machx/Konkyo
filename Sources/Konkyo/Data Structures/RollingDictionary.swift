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
	var keys: Array<Key>
	var dictionary: Dictionary<Key,Value>
	var limit: Int
	
	init(limit keyLimit: Int) {
		keys = [Key]()
		dictionary = [Key: Value]()
		limit = keyLimit
	}
	
	subscript(key: Key) -> Value? {
		get {
			dictionary[key]
		}
		set(newValue) {
			guard let newValue = newValue else {
				self.dictionary.removeValue(forKey: key)
				return
			}
			let oldValue = self.dictionary.updateValue(newValue!, forKey: key)
			if oldValue == nil {
				self.keys.append(key)
			}
			guard keys.count <= limit else {
				dictionary.removeValue(forKey: keys[0])
			}
		}
	}
}
