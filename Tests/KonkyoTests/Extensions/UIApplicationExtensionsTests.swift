///
/// Copyright 2026 Colin Wheeler
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

#if canImport(UIKit)
import UIKit
import Konkyo
import Testing

@Suite("UIApplication Extension Tests")
struct UIApplicationExtensionsTests {

	/// In a headless test environment there are no active scenes, so getKeyWindow()
	/// must return nil rather than crash.
	@Test("getKeyWindow() returns nil when no foreground scene is active")
	@MainActor
	func testGetKeyWindowReturnsNilWithNoActiveScene() {
		let window = UIApplication.shared.getKeyWindow()
		#expect(window == nil)
	}
}
#endif
