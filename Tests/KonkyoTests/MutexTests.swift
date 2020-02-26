//
//  File.swift
//  
//
//  Created by Colin Wheeler on 2/25/20.
//

import XCTest
import Foundation
import Konkyo

final class MutexTests: XCTestCase {
	
	func testMutex() {
		let mutex = Mutex()
		var total = 0
		DispatchQueue.concurrentPerform(iterations: 10000) { (index) in
			mutex.lock()
			total += index
			mutex.unlock()
		}
		
		XCTAssertEqual(total, 49995000)
	}
	
	
    static var allTests = [
        ("testMutex", testMutex),
    ]
}
