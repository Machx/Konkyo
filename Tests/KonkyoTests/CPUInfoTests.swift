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

import Testing
import Konkyo

final class MockSysctlProvider: SysctlProviding {
	let returnValue: Int
	init(returnValue: Int) {
		self.returnValue = returnValue
	}
	func sysctlInt(for name: String) -> Int {
		return returnValue
	}
}

final class CPUInfoTests: XCTestCase {
	func testCpuCoreCountReturnsMockValue() {
		let mockProvider = MockSysctlProvider(returnValue: 42)
		let cpuInfo = CPUInfo(sysctlProvider: mockProvider)
		XCTAssertEqual(cpuInfo.cpuCoreCount(), 42)
	}
}
