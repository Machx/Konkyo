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

public protocol SysctlProviding {
	func sysctlInt(for name: String) -> Int
}

public struct RealSysctlProvider: SysctlProviding {
	public init() {}

	public func sysctlInt(for name: String) -> Int {
		var size = MemoryLayout<Int>.size
		var value: Int = 0
		sysctlbyname(name, &value, &size, nil, 0)
		return value
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
