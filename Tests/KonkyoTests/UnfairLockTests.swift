//
//  File.swift
//  
//
//  Created by Colin Wheeler on 3/2/20.
//

import Foundation
import XCTest
import Konkyo

@available(OSX 10.12, *)
final class UnfairLockTests: XCTestCase {
	
	func testUnfairLock() {
		let lock = UnfairLock()
		var total = 0
		let iterations = Int.random(in: 5000...15000)
		DispatchQueue.concurrentPerform(iterations: iterations) { (index) in
			lock.lock()
			total += index + 1 // Adjust because indexes start at 0.
			lock.unlock()
		}
		
		let expected = (iterations * (iterations + 1)) / 2
		
		XCTAssertEqual(total, expected, "Failed with Iterations: \(iterations)")
	}
	
	static var allTests = [
        ("testUnfairLock", testUnfairLock),
    ]
}
