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

public extension String {

	/// Returns if the string value is an absolute URL.
	///
	/// `URL(string:)` is very permissive (since iOS 17 / macOS 14 it percent-encodes
	/// invalid characters, so strings like `"not a url"` parse), so this additionally requires:
	/// - a non-empty scheme (`"example.com"` and relative paths like `"path/to/resource"` are rejected).
	/// - a non-empty host when the URL has an authority component (`"https://"` is rejected),
	///   except for `file` URLs, which may legitimately have an empty host (`file:///path`).
	///
	/// URLs without an authority, such as `mailto:user@example.com`, are accepted.
	///
	/// - returns: True if the string value is an absolute URL.
	var isValidURL: Bool {
		guard let url = URL(string: self),
			  let scheme = url.scheme, !scheme.isEmpty else { return false }
		guard scheme.lowercased() != "file" else { return true }
		// Only URLs written with an authority ("scheme://...") need a host.
		guard hasAuthority(after: scheme) else { return true }
		return !(url.host(percentEncoded: false) ?? "").isEmpty
	}

	/// True when the character data following `scheme:` begins with `//`.
	private func hasAuthority(after scheme: String) -> Bool {
		dropFirst(scheme.count + 1).hasPrefix("//")
	}
}
