//
//  File.swift
//  
//
//  Created by Colin Wheeler on 1/7/20.
//

import Foundation
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
final class OperationTests: XCTestCase {
	
	/// Test Operation Access on isExecuting isFinished in AsyncOperationBase
	func testOperation() {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		
		let op = IncrementOp(value: 1)
		queue.addOperation(op)
		
		queue.waitUntilAllOperationsAreFinished()
		XCTAssertEqual(op.value, 2)
	}
}
