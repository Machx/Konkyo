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
import Konkyo
import Testing

@Suite
struct URLExtensionTests {

	@Test("Test URL Extension Valid URL")
	func testURLExtensionValidURL() {
		let valid = "https://www.apple.com"
		#expect(valid.isValidURL)
	}

	@Test("Test URLExtension Invalid URL")
	func testURLExtensionInvalidURL() {
		// Public Source code showed it just checked for non empty string
		let invalid = ""
		#expect(!invalid.isValidURL)
	}
}
