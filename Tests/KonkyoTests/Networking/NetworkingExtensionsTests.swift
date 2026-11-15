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

	@Test("URL with port number is valid")
	func testURLWithPort() {
		#expect("https://example.com:8080/api".isValidURL)
	}

	@Test("URL with user info is valid")
	func testURLWithUserInfo() {
		#expect("https://user:password@example.com".isValidURL)
	}

	@Test("Relative path is not a valid URL")
	func testRelativePathIsInvalid() {
		// URL(string:) accepts relative URLs, but they have no scheme.
		#expect(!"path/to/resource".isValidURL)
	}

	@Test("Simple identifier is not a valid URL")
	func testSimpleIdentifierIsInvalid() {
		#expect(!"hello".isValidURL)
	}

	@Test("Scheme-less host is not a valid URL")
	func testSchemelessHostIsInvalid() {
		#expect(!"example.com".isValidURL)
		#expect(!"www.apple.com/path".isValidURL)
	}

	@Test("Free text with spaces is not a valid URL")
	func testFreeTextIsInvalid() {
		#expect(!"not a url".isValidURL)
		#expect(!"hello world".isValidURL)
		#expect(!"not a url $$".isValidURL)
		#expect(!"http://exa mple.com".isValidURL)
	}

	@Test("Scheme with an empty host is not a valid URL")
	func testEmptyHostIsInvalid() {
		#expect(!"http://".isValidURL)
		#expect(!"https:///path".isValidURL)
		#expect(!"://".isValidURL)
		#expect(!"://example.com".isValidURL)
	}

	@Test("Scheme-only authority-less URLs are valid")
	func testAuthorityLessURLs() {
		#expect("tel:+15551234567".isValidURL)
		#expect("mailto:user@example.com".isValidURL)
	}

	@Test("Scheme is matched case-insensitively for file URLs")
	func testFileSchemeCase() {
		#expect("FILE:///Users/test/file.txt".isValidURL)
	}
}
