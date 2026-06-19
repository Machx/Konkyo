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

	@Test("URL with query parameters is valid")
	func testURLWithQueryParameters() {
		#expect("https://example.com?q=swift&page=1".isValidURL)
	}

	@Test("URL with fragment is valid")
	func testURLWithFragment() {
		#expect("https://example.com#section".isValidURL)
	}

	@Test("URL with path components is valid")
	func testURLWithPathComponents() {
		#expect("https://example.com/path/to/resource".isValidURL)
	}

	@Test("HTTP URL is valid")
	func testHTTPURL() {
		#expect("http://example.com".isValidURL)
	}

	@Test("file:// URL is valid")
	func testFileURL() {
		#expect("file:///Users/test/file.txt".isValidURL)
	}

	@Test("mailto URL is valid")
	func testMailtoURL() {
		#expect("mailto:user@example.com".isValidURL)
	}

	@Test("ftp URL is valid")
	func testFTPURL() {
		#expect("ftp://files.example.com/some/path".isValidURL)
	}
}
