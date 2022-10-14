//
//  NSLockExtensions.swift
//  
//
//  Created by Colin Wheeler on 10/14/22.
//

import Foundation

public extension NSLock {

	func withLock(_ block: ()->Void) {
		self.lock()
		block()
		self.unlock()
	}
}
