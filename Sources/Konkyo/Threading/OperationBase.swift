//
//  File.swift
//  
//
//  Created by Colin Wheeler on 11/29/19.
//

import Foundation

open class BaseOperation: Operation {
	
	var _isExecuting: Bool = false
	open override var isExecuting: Bool {
		get { _isExecuting }
		set {
			willChangeValue(for: \.isExecuting)
			_isExecuting = newValue
			didChangeValue(for: \.isExecuting)
		}
	}
	
	var _isFinished: Bool = false
	open override var isFinished: Bool {
		get { _isFinished }
		set {
			willChangeValue(for: \.isFinished)
			_isFinished = newValue
			didChangeValue(for: \.isFinished)
		}
	}
}
