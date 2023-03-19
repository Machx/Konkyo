//
//  File.swift
//  
//
//  Created by Colin Wheeler on 3/19/23.
//

import Foundation

public final class Promise<T,E> {
	public var value: T?
	public var error: E?
}
