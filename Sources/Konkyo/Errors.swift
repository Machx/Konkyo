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
/// AppError - loadingError
/// └─ ProfileError - noSavedProfileError
///    └─ DatabaseError - noRecordFound
///
public protocol TraceableError: Error {
    var containedError: Error { get }
}

public extension Error {
    /// Builds a formatted, recursive description of an error chain.
    ///
    /// If `self` conforms to `TraceableError`, its `containedError` is unwrapped
    /// and appended on the next line, indented and prefixed with `└─`, repeating
    /// until an error is reached that does not conform to `TraceableError`. Each
    /// line takes the form `TypeName - caseName`.
    ///
    /// For example, an `AppError.loadingError` wrapping a
    /// `ProfileError.noSavedProfileError` wrapping a `DatabaseError.noRecordFound`
    /// produces:
    /// ```
    /// AppError - loadingError
    /// └─ ProfileError - noSavedProfileError
    ///    └─ DatabaseError - noRecordFound
    /// ```
    ///
    /// `NSError` instances (and subclasses) are also unwrapped even though they
    /// don't conform to `TraceableError`: their line is formatted as
    /// `TypeName - domain (code)`, and the chain continues into their
    /// `underlyingErrors`/`NSUnderlyingErrorKey` error, if one is present.
    func traceableErrorDescription() -> String {
        var lines: [String] = []
        var current: Error = self
        var depth = 0

        while true {
            let prefix = depth == 0 ? "" : String(repeating: "   ", count: depth - 1) + "└─ "
            lines.append(prefix + Self.describe(current))

            if let traceable = current as? TraceableError {
                current = traceable.containedError
            } else if let underlying = Self.underlyingNSError(of: current) {
                current = underlying
            } else {
                break
            }
            depth += 1
        }

        return lines.joined(separator: "\n")
    }

    /// Formats a single error's line as `TypeName - caseName`, or, for an
    /// `NSError` (or subclass), `TypeName - domain (code)`.
    private static func describe(_ error: Error) -> String {
        let typeName = String(describing: type(of: error))

        guard type(of: error) is NSError.Type else {
            return "\(typeName) - \(caseName(of: error))"
        }

        let nsError = error as NSError
        return "\(typeName) - \(nsError.domain) (\(nsError.code))"
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

    /// Returns the error's wrapped `underlyingErrors`/`NSUnderlyingErrorKey`
    /// error, if `error` is truly an `NSError` (or subclass) instance and one
    /// is present. Every Swift error bridges to `NSError` on demand, so this
    /// checks the error's dynamic type rather than attempting an `as?` cast.
    private static func underlyingNSError(of error: Error) -> Error? {
        guard type(of: error) is NSError.Type else {
            return nil
        }

        let nsError = error as NSError
        return nsError.underlyingErrors.first ?? nsError.userInfo[NSUnderlyingErrorKey] as? Error
    }
}
