///
/// Copyright 2022 Colin Wheeler
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

public extension NSLock {
	
	/// Convenience for locking the lock, performing action(s) and then unlocking the lock
	/// - Parameter block: Captured actions to perform while lock is locked
	func withLock(_ block: ()->Void) {
		self.lock()
		block()
		self.unlock()
	}
	
	/// Convenience for trying to unlock the lock and executing completion if its available for locking.
	///
	/// If the lock is available to be locked, then it is and the block is executed, otherwise nothing happens.
	///
	/// - Parameter withLock: Block to be executed if the lock is available for locking.
	func tryLock(_ withLock: ()->Void) {
		guard self.try() else { return }
		withLock()
		self.unlock()
	}
}
