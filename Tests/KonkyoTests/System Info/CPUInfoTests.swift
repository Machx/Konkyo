///
/// Copyright 2025 Colin Wheeler
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
import Konkyo
import Testing

final class MockSysctlProvider: SysctlProviding {
	let returnValue: Int
	init(returnValue: Int) {
		self.returnValue = returnValue
	}
	func sysctlInt(for name: String) -> Int {
		return returnValue
	}
}

@Suite
struct CPUInfoTests {

	@Test("Mock provider returns injected value")
	func testCpuCoreCountReturnsMockValue() {
		let mockProvider = MockSysctlProvider(returnValue: 42)
		let cpuInfo = CPUInfo(sysctlProvider: mockProvider)
		#expect(cpuInfo.cpuCoreCount() == 42)
	}

	@Test("Real provider returns a positive core count")
	func testCpuCoreCountReturnsRealValue() {
		let cpuInfo = CPUInfo()
		#expect(cpuInfo.cpuCoreCount() > 0)
	}

	@Test("Mock provider with single core returns 1")
	func testMockWithSingleCore() {
		let cpuInfo = CPUInfo(sysctlProvider: MockSysctlProvider(returnValue: 1))
		#expect(cpuInfo.cpuCoreCount() == 1)
	}

	@Test("Mock provider with large core count returns that count")
	func testMockWithLargeCoreCount() {
		let cpuInfo = CPUInfo(sysctlProvider: MockSysctlProvider(returnValue: 128))
		#expect(cpuInfo.cpuCoreCount() == 128)
	}

	@Test("Real provider reads 32-bit values")
	func testRealProviderReads32BitValue() {
		// hw.ncpu is a 32-bit int.
		let provider = RealSysctlProvider()
		#expect(provider.sysctlInt(for: "hw.ncpu") == ProcessInfo.processInfo.processorCount)
	}

	@Test("Real provider reads 64-bit values")
	func testRealProviderReads64BitValue() {
		// hw.memsize is a 64-bit int.
		let provider = RealSysctlProvider()
		#expect(provider.sysctlInt(for: "hw.memsize") == Int(ProcessInfo.processInfo.physicalMemory))
	}

	@Test("Real provider returns 0 for an unknown name")
	func testRealProviderUnknownName() {
		#expect(RealSysctlProvider().sysctlInt(for: "konkyo.does.not.exist") == 0)
	}

	@Test("Real provider returns 0 for a value that is not a 32 or 64-bit integer")
	func testRealProviderNonIntegerValue() {
		// kern.ostype is the string "Darwin" (7 bytes with its terminator).
		#expect(RealSysctlProvider().sysctlInt(for: "kern.ostype") == 0)
	}

	@Test("Mock provider returning 0 passes through as-is")
	func testMockReturningZeroPassesThrough() {
		let cpuInfo = CPUInfo(sysctlProvider: MockSysctlProvider(returnValue: 0))
		#expect(cpuInfo.cpuCoreCount() == 0)
	}
}
