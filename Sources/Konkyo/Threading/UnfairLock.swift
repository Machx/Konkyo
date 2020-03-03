//
//  File.swift
//  
//
//  Created by Colin Wheeler on 3/1/20.
//

import Foundation

@available(macOS 10.12,iOS 10.10, macCatalyst 13.0, tvOS 10.0, watchOS 3.0, *)
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
