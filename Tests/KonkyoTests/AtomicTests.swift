//
//  File.swift
//  
//
//  Created by Colin Wheeler on 12/27/19.
//

import Foundation
import XCTest

@available(OSX 10.12, *)
final class AtomicTests: XCTestCase {
	
	func testAtomic() {
		XCTAssertEqual(3, 3)
	}
	
	static var allTests = [
		("testAtomic", testAtomic),
    ]
}
