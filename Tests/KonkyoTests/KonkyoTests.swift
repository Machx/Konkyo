import XCTest
@testable import Konkyo

@available(OSX 10.12, *)
final class KonkyoTests: XCTestCase {
	
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Konkyo.version, 1)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
