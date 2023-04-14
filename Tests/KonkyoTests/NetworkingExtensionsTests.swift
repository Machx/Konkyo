//
//  File.swift
//  
//
//  Created by Colin Wheeler on 4/13/23.
//

import Foundation
import XCTest
import Konkyo

final class URLExtensionTests: XCTestCase {

	func testURLExtensionValidURL() {
		let valid = "https://www.apple.com"
		XCTAssertTrue(valid.isValidURL)
	}

	func testURLExtensionInvalidURL() {
		let invalid = "quizzyjimbo"
		XCTAssertTrue(invalid.isValidURL)
	}
}
