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
	/// Scenes in the foreground-active state are searched first. If none of them has a key
	/// window, scenes that are foreground-inactive are searched too, because a scene is briefly
	/// inactive while the app switcher, Control Center or a system alert is showing, or while the
	/// scene is transitioning to or from the foreground, and its key window is still the one you want.
	/// Scenes in the background or that are unattached are never searched.
	///
	/// - Returns: The Key window for a UIKit Application or nil or one could not be found.
	func getKeyWindow() -> UIWindow? {
		let scenes = connectedScenes.compactMap { $0 as? UIWindowScene }
		for state in [UIScene.ActivationState.foregroundActive, .foregroundInactive] {
			let window = scenes
				.lazy
				.filter { $0.activationState == state }
				.flatMap { $0.windows }
				.first(where: { $0.isKeyWindow })
			if let window { return window }
		}
		return nil
	}
}
#endif
