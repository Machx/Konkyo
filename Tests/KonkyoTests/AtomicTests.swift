//
//  File.swift
//  
//
//  Created by Colin Wheeler on 12/27/19.
//

import Foundation
import XCTest
@testable import Konkyo

@available(OSX 10.12, *)
final class AtomicTests: XCTestCase {
	
	func testAtomic() {
		let numbers = Atomic<[Int]>([])
		let queue = DispatchQueue(label: "com.konkyo.unittests", attributes: [.concurrent])
		let group = DispatchGroup()
		
		for i in 1...10000 {
			queue.async(group:group) {
				numbers.mutate { (numbers) in
					numbers.append(i)
				}
			}
		}
		
		group.wait()
		
		XCTAssertEqual(numbers.value.count, 10000)
	}
	
	static var allTests = [
		("testAtomic", testAtomic),
    ]
}
