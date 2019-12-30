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

import XCTest
@testable import Konkyo

public class IncrementOp: AsynchronousOperationBase {
	let queue = DispatchQueue(label: "com.thing")
	
	var value: Int = 0
	
	public init(value: Int) {
		super.init()
		self.value = value
	}
	
	public override func start() {
		isExecuting = true
		queue.async { [weak self] in
			guard let self = self else { return }
			self.value += 1
			self.isFinished = true
		}
	}
}

@available(OSX 10.12, *)
final class KonkyoTests: XCTestCase {
	
    func testVersion() {
		let version = Konkyo.Version()
		XCTAssertEqual(version.major, 0)
		XCTAssertEqual(version.minor, 1)
		XCTAssertEqual(version.bugfix, 0)
    }
	
	/// Test Operation Access on isExecuting isFinished in AsyncOperationBase
	func testOperation() {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		
		let op = IncrementOp(value: 1)
		queue.addOperation(op)
		
		queue.waitUntilAllOperationsAreFinished()
		XCTAssertEqual(op.value, 2)
	}

    static var allTests = [
        ("testVersion", testVersion),
    ]
}
