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
        var lines: [String] = []
        var current: Error = self
        var depth = 0

        while true {
            let typeName = String(describing: type(of: current))
            let caseDescription = Self.caseName(of: current)
            let prefix = depth == 0 ? "" : String(repeating: "   ", count: depth - 1) + "└─ "
            lines.append("\(prefix)\(typeName) - \(caseDescription)")

            guard let traceable = current as? TraceableError else {
                break
            }
            current = traceable.containedError
            depth += 1
        }

        return lines.joined(separator: "\n")
    }

    /// Returns just the enum case name for `error`, without any associated values,
    /// falling back to the full description for non-enum errors.
    private static func caseName(of error: Error) -> String {
        let mirror = Mirror(reflecting: error)
        if mirror.displayStyle == .enum, let label = mirror.children.first?.label {
            return label
        }
        return String(describing: error)
    }
}
