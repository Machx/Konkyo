//
//  File.swift
//  
//
//  Created by Colin Wheeler on 1/24/20.
//

import Foundation
import XCTest
@testable import Konkyo

final class InitializationTests: XCTestCase {
	
	func testCreationOperator() {
		let thing = MyClass() <- {
			$0.myNum = 5
		}
		
		XCTAssertEqual(thing.myNum, 5)
	}
	
	static var allTests = [
		("testCreationOperator", testCreationOperator)
    ]
}
