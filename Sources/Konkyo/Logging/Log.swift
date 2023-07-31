///
/// Copyright 2021 Colin Wheeler
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
import os.log
import CoreGraphics.CGGeometry

/// Log is a struct meant to be a central access point & extension for more logs.
///
/// Log can be extended to add central access to a variety of logs like so.
/// ```swift
/// extension Log {
/// 	static let myLogger = Logger(subsystem: "com.myapp.networking", category: "networking")
/// }
/// ```
public struct Log {
	internal static let konkyo = Logger(subsystem: "com.konkyo", category: "general")
}

/// Convenience function for returning the File, Function and Line string for use with OSLog
/// - Parameters:
///   - file: The file the print message is used in. Obtained automatically.
///   - function: The function the print message is used in. Obtained automatically.
///   - line: The line of the file the print message is used in. Obtained automatically.
/// - Returns: A string formatted with the print log location.
public func logLocation(file: String = #file,
						function: String = #function,
						line: Int = #line) -> String {
	"\n\n\(file) - \(function) - \(line)"
}
