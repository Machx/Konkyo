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
import Konkyo
import Testing

final class MyOperation: AsynchronousOperationBase, @unchecked Sendable {
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

@Test("Test Asynchronous Operation")
func testAsyncOperation() {
	let operation = MyOperation()
	#expect(operation.isAsynchronous)

	let queue = OperationQueue()
	queue.addOperation(operation)
	queue.waitUntilAllOperationsAreFinished()

	#expect(operation.num == 152)
}
/// Plain subclass with no extra state — used to exercise the base class's
/// isExecuting / isFinished synchronization under concurrent access.
final class BareOp: AsynchronousOperationBase, @unchecked Sendable {}

@Test("isExecuting and isFinished are safe under concurrent reads and writes")
func testConcurrentStateAccess() async {
	let op = BareOp()

	await withTaskGroup(of: Void.self) { group in
		// Many concurrent readers — would race the writer without the mutex.
		for _ in 0..<8 {
			group.addTask {
				for _ in 0..<10_000 {
					_ = op.isExecuting
					_ = op.isFinished
				}
			}
		}
		// Writer transitions state through the standard Operation lifecycle.
		group.addTask {
			op.isExecuting = true
			op.isExecuting = false
			op.isFinished = true
		}
	}

	#expect(op.isExecuting == false)
	#expect(op.isFinished == true)
}

/// Observer that records every KVO callback it receives.
private final class StateChangeObserver: NSObject, @unchecked Sendable {
	var count = 0
	override func observeValue(forKeyPath keyPath: String?,
							   of object: Any?,
							   change: [NSKeyValueChangeKey : Any]?,
							   context: UnsafeMutableRawPointer?) {
		count += 1
	}
}

@Test("Initial isExecuting and isFinished are both false")
func testInitialStateIsFalse() {
	let op = BareOp()
	#expect(op.isExecuting == false)
	#expect(op.isFinished == false)
}

@Test("isAsynchronous returns true")
func testIsAsynchronousReturnsTrue() {
	let op = BareOp()
	#expect(op.isAsynchronous == true)
}

@Test("Setting isExecuting to its current value does not fire KVO")
func testIsExecutingIdempotentDoesNotFireKVO() {
	let op = BareOp()
	op.isExecuting = true

	let observer = StateChangeObserver()
	op.addObserver(observer, forKeyPath: "isExecuting", options: [.new], context: nil)
	op.isExecuting = true // Same value — must not fire KVO.
	op.removeObserver(observer, forKeyPath: "isExecuting")
	#expect(observer.count == 0)
}

@Test("Setting isFinished to its current value does not fire KVO")
func testIsFinishedIdempotentDoesNotFireKVO() {
	let op = BareOp()

	let observer = StateChangeObserver()
	op.addObserver(observer, forKeyPath: "isFinished", options: [.new], context: nil)
	op.isFinished = false // Same as the initial value — must not fire KVO.
	op.removeObserver(observer, forKeyPath: "isFinished")
	#expect(observer.count == 0)
}

@Test("Transitioning isExecuting fires KVO exactly once")
func testIsExecutingFiresKVO() {
	let op = BareOp()

	let observer = StateChangeObserver()
	op.addObserver(observer, forKeyPath: "isExecuting", options: [.new], context: nil)
	op.isExecuting = true
	op.removeObserver(observer, forKeyPath: "isExecuting")
	#expect(observer.count == 1)
}

@Test("Transitioning isFinished fires KVO exactly once")
func testIsFinishedFiresKVO() {
	let op = BareOp()

	let observer = StateChangeObserver()
	op.addObserver(observer, forKeyPath: "isFinished", options: [.new], context: nil)
	op.isFinished = true
	op.removeObserver(observer, forKeyPath: "isFinished")
	#expect(observer.count == 1)
}

