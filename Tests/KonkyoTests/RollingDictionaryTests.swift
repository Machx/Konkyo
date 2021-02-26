//
//  File.swift
//  
//
//  Created by Colin Wheeler on 2/25/21.
//

import Foundation
import XCTest
import Konkyo

final class RollingDictionaryTests: XCTestCase {
	
	func testBasicRollingDictionaryWith1Value() {
		var dictionary = RollingDictionary<String,Int>(limit: 1)
		
		dictionary["Ted"] = 1
		
		XCTAssertEqual(dictionary["Ted"], 1)
		
		dictionary["Lasso"] = 2
		
		XCTAssertEqual(dictionary["Lasso"], 2)
		XCTAssertNil(dictionary["Ted"])
	}
}
