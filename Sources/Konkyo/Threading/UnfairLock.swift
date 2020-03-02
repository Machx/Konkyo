//
//  File.swift
//  
//
//  Created by Colin Wheeler on 3/1/20.
//

import Foundation

@available(macOS 10.12, *)
public final class UnfairLock {
	private typealias UnfairLock = os_unfair_lock
	
	private var unfairLock: UnfairLock = os_unfair_lock()
	
	public init() {
	}
	
	public func lock() {
		os_unfair_lock_lock(&unfairLock)
	}
	
	public func unlock() {
		os_unfair_lock_unlock(&unfairLock)
	}
	
	public func tryLock() -> Bool {
		return os_unfair_lock_trylock(&unfairLock)
	}
}
