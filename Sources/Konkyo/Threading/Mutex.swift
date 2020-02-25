//
//  File.swift
//  
//
//  Created by Colin Wheeler on 2/24/20.
//

import Foundation

public final class Mutex {
	private typealias _MutexPointer = UnsafeMutablePointer<pthread_mutex_t>
	
	private var mutex = _MutexPointer.allocate(capacity: 1)
	
	init() {
		pthread_mutex_init(mutex, nil)
	}
	
	deinit {
		pthread_mutex_destroy(mutex)
		mutex.deinitialize(count: 1)
		mutex.deallocate()
	}
	
	public func lock() {
		pthread_mutex_lock(mutex)
	}
	
	public func unlock() {
		pthread_mutex_unlock(mutex)
	}
	
	public func tryLock() -> Bool {
		return pthread_mutex_trylock(mutex) == 0
	}
}
