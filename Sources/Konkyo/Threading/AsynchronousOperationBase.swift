///
/// Copyright 2019 Colin Wheeler
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


/// Operation Subclass that overrides isExecuting and isFinished while doing safe KVO.
open class AsynchronousOperationBase: Operation {
	
	open override var isAsynchronous: Bool {
		return true
	}
	
	private var _isExecuting: Bool = false
	/// Automatically override the isExecuting to make it assignable and do KVO
	open override var isExecuting: Bool {
		get { _isExecuting }
		set {
			willChangeValue(for: \.isExecuting)
			_isExecuting = newValue
			didChangeValue(for: \.isExecuting)
		}
	}
	
	private var _isFinished: Bool = false
	/// Automatically override the isFinished to make it assignable and do KVO
	open override var isFinished: Bool {
		get { _isFinished }
		set {
			willChangeValue(for: \.isFinished)
			_isFinished = newValue
			didChangeValue(for: \.isFinished)
		}
	}
}
