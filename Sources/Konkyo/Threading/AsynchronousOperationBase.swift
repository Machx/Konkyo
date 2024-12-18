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


/// Operation Subclass that overrides isExecuting and isFinished while doing safe KVO.
///
/// Automatically setup Operation so isAsynchronous returns true and isExecuting and
/// isFinished are settable and automatically trigger KVO willChangeValue(for:) and
/// didChangeValue(for:) notifications
///
/// 1.0.0
open class AsynchronousOperationBase: Operation, @unchecked Sendable {
	
	open override var isAsynchronous: Bool {
		return true
	}
	
	private var _isExecuting: Bool = false
	open override var isExecuting: Bool {
		get { _isExecuting }
		set {
			guard _isExecuting != newValue else { return }
			willChangeValue(for: \.isExecuting)
			_isExecuting = newValue
			didChangeValue(for: \.isExecuting)
		}
	}
	
	private var _isFinished: Bool = false
	open override var isFinished: Bool {
		get { _isFinished }
		set {
			guard _isFinished != newValue else { return }
			willChangeValue(for: \.isFinished)
			_isFinished = newValue
			didChangeValue(for: \.isFinished)
		}
	}
}
