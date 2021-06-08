///
/// Copyright 2020 Colin Wheeler
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

/// Allows for easier time initializing objects
/// Instead of
/// ```
/// let myButton = {
///    let button = UIButton()
///    //.. customize button
///    return button
///  }()
/// ```
/// you can instead do
/// ```
/// let myButton = UIButton() <- {
///     $0.setTitle("title", for: .normal)
///     // customize...
/// }
/// ```

infix operator <-


/// Takes the LHS and passes it to a function which is executed and the result returned
/// - Parameters:
///   - object: the object to be passed to function and returned
///   - function: the function to operate on object
/// - Returns: the result of function applied to object
public func <-<T>(object: T, function: (T)->Void) -> T {
	function(object)
	return object
}
