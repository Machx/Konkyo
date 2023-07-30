///
/// Copyright 2023 Colin Wheeler
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

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
