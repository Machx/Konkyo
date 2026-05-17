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
import SwiftUI

/// This has been imported into UnitTestKit, however I don't want to pull another
/// package into this one just for 1 function so a copy will remain here.
extension View {
	func isOfType<T>(_ type: T.Type) -> Bool {
		return self is T
	}
}

struct ViewExtensionTest {

    @Test @MainActor
	func testViewExtension() async throws {
		let view = Text("Hello")
		let generic = view.typeErased
		let result = generic.isOfType(Text.self)
		#expect(result == false)
    }
}
