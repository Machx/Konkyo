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
import XCTest
import Konkyo

final class MyOperation: AsynchronousOperationBase {
	var num = 1
	
	override func start() {
		isExecuting = true
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self else { return }
			self.num = 152
			self.isFinished = true
		}
	}
}

final class AsynchronousOperationBaseTests: XCTestCase {
	
	func testAsyncOperation() {
		let operation = MyOperation()
		XCTAssertTrue(operation.isAsynchronous)
		
		let queue = OperationQueue()
		queue.addOperation(operation)
		queue.waitUntilAllOperationsAreFinished()
		
		XCTAssertEqual(operation.num, 152)
	}
}
