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

#if canImport(UIKit)
import UIKit

public extension UIApplication {
	/// Returns the Key Window for a UIKit application or nil if one could not be found.
	///
	/// - Returns: The Key window for a UIKit Application or nil or one could not be found.
	func getKeyWindow() -> UIWindow? {
		guard let activeScenes = connectedScenes.filter({ $0.activationState == .foregroundActive }) as? Set<UIWindowScene> else {
			return nil
		}
		guard let window = activeScenes.first?.windows.first as? UIWindow else { return nil }
		return window
	}
}

#endif
