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

public final class Mutex {
	private typealias _MutexPointer = UnsafeMutablePointer<pthread_mutex_t>
	
	private var mutex = _MutexPointer.allocate(capacity: 1)
	
	init() {
		pthread_mutex_init(mutex, nil)
	}
	
	deinit {
		pthread_mutex_destroy(mutex)
		mutex.deinitialize(count: 1)
		mutex.deallocate()
	}
	
	public func lock() {
		pthread_mutex_lock(mutex)
	}
	
	public func unlock() {
		pthread_mutex_unlock(mutex)
	}
	
	public func tryLock() -> Bool {
		return pthread_mutex_trylock(mutex) == 0
	}
}
