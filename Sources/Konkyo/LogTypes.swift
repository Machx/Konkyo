//
//  LogTypes.swift
//  
//
//  Created by Colin Wheeler on 7/29/23.
//

import Foundation

extension CGPoint: CustomStringConvertible {
	/// Returns a string representation of the point made by rounding to 2 decimal places.
	public var description: String {
		"CGPoint { x: \(String(format: "%.2f", x)) y: \(String(format: "%.2f", y))"
	}
}

extension CGRect: CustomStringConvertible {
	/// Returns a string representation of the rect made by rounding its x,y,width and height to 2 decimal places.
	public var description: String {
		"""
		CGRect {
			Origin: CGPoint { x: \(String(format: "%.2f", origin.x)) y: \(String(format: "%.2f", origin.y)) }
			  Size: CGSize { width: \(String(format: "%.2f", size.width)) height: \(String(format: "%.2f", size.height)) }
		}
		"""
	}
}
