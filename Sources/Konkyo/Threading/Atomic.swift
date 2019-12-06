//
//  File.swift
//  
//
//  Created by Colin Wheeler on 12/5/19.
//

import Foundation

public final class Atomic<Value> {
	private var _value: Value
	private let queue = DispatchQueue(label: "com.Konkyo.Atomic.\(String(describing: Value))")
	
	public var value: Value {
		get {
			return queue.sync { self._value }
		}
	}
	
	public func mutate(_ transform: (inout Value) -> Void) {
		queue.sync {
			transform(&self._value)
		}
	}
}
