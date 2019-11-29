//
//  File.swift
//
//
//  Created by Colin Wheeler on 11/29/19.
//

import Foundation

@propertyWrapper
struct Atomic<Value> {
	var value: Value
	var queue = DispatchQueue(label: "com.Konkyo.Atomic.\(String(describing: Value.self))")
	
	var wrappedValue: Value {
		get { queue.sync { value } }
		set { queue.sync { value = newValue } }
	}
}
