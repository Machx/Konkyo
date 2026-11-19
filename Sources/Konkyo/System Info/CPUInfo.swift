///
/// Copyright 2020 Colin Wheeler
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
import Darwin.sys.sysctl

/// Protocol for making this easier to abstract away and
/// do better unit testing.
public protocol SysctlProviding {
	func sysctlInt(for name: String) -> Int
}

public struct RealSysctlProvider: SysctlProviding {
	public init() {}

	/// Reads an integer sysctl value by name.
	///
	/// sysctl integer values are either 32-bit (such as `hw.ncpu`) or 64-bit (such as `hw.memsize`).
	/// The size of the value is queried first and the value is read into a buffer of exactly that
	/// size, so both widths are read correctly without relying on byte order or on the kernel
	/// only partially filling a larger buffer.
	///
	/// - Parameter name: The sysctl name, such as `"hw.ncpu"`.
	/// - Returns: The value, or `0` if the name doesn't exist, the call fails, or the value is not
	///   a 32-bit or 64-bit integer.
	public func sysctlInt(for name: String) -> Int {
		var size = 0
		guard sysctlbyname(name, nil, &size, nil, 0) == 0 else { return 0 }

		switch size {
		case MemoryLayout<Int32>.size:
			var value: Int32 = 0
			guard sysctlbyname(name, &value, &size, nil, 0) == 0 else { return 0 }
			return Int(value)
		case MemoryLayout<Int64>.size:
			var value: Int64 = 0
			guard sysctlbyname(name, &value, &size, nil, 0) == 0 else { return 0 }
			return Int(value)
		default:
			return 0
		}
	}
}

public final class CPUInfo {
	private let sysctlProvider: SysctlProviding

	public init(sysctlProvider: SysctlProviding = RealSysctlProvider()) {
		self.sysctlProvider = sysctlProvider
	}

	public func cpuCoreCount() -> Int {
		return sysctlProvider.sysctlInt(for: "hw.ncpu")
	}
}
