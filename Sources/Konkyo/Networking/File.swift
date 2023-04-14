//
//  File.swift
//  
//
//  Created by Colin Wheeler on 4/13/23.
//

import Foundation

public extension String {
	var isValidURL: Bool {
		guard let _ = URL(string: self) else { return false }
		return true
	}
}
