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

/// TraceableError is a protocol that allows developers to see  the path an error takes
/// Exmple:
///
/// AppError - loadingError
/// └─ ProfileError - noSavedProfileError
///    └─ DatabaseError - noRecordFound
///    
public protocol TraceableError: Error {
    var containedError: Error { get }
}

public extension Error {
    func traceableErrorDescription() -> String {
        func prettyDescription(error: Error, indent: String = "") -> String {
            ""
        }
        return prettyDescription(error: self, indent: "")
    }
}
