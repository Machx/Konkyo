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
	
	func testBasicRollingDictionary() {
		var dictionary = RollingDictionary<String,Int>(limit: 1)
		
		dictionary["Ted"] = 1
		
		let keys1 = dictionary.keys
		
		XCTAssertEqual(keys1, 1)
		XCTAssertEqual(["Ted"], keys1)
		
		dictionary["Lasso"] = 2
	}
}
