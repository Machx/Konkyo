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

import Foundation

public extension Result {

	/// If the Result value is failure, then this returns the error associated with it, otherwise nil.
	///
	/// This is intended to be used in cases where you may be in certain scopes, such as the else clause
	/// of a guard statement and need to directly access the error of the failure case.
	/// ```swift
	/// let result = await getResult()
	/// guard case .success = result else {
	///     if let error = result.failureError {
	///         // report error
	///     }
	///     return
	/// }
	/// ```
	var failureError: Failure? {
		if case .failure(let error) = self {
			return error
		} else {
			return nil
		}
	}
}
