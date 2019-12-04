import XCTest
@testable import Konkyo

@available(OSX 10.12, *)
final class KonkyoTests: XCTestCase {
	
	@Atomic var numbers: [Int] = []
	
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Konkyo.version, 1)
		
		let queue = DispatchQueue(label: "com.konkyo.test", attributes: [.concurrent])
		let group = DispatchGroup()
		
		for _ in 0..<1000 {
			queue.async(group: group) { [weak self] in
				guard let self = self else { return }
				self.numbers.append(Int.random(in: 1...500))
			}
		}
		
		group.wait()
		
		XCTAssertEqual(numbers.count, 1000)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
