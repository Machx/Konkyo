//
//  File.swift
//  
//
//  Created by Colin Wheeler on 1/22/20.
//

import Foundation

infix operator <-
public func <-<T>(object: T, function: (T)->Void) -> T {
	function(object)
	return object
}
