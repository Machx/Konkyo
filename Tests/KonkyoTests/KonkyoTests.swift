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
	
	func testAtomic() {
		let numbers = Atomic<[Int]>([])
		let queue = DispatchQueue(label: "com.konkyo.unittests", attributes: [.concurrent])
		let group = DispatchGroup()
		
		for i in 1...100 {
			queue.async(group:group) {
				numbers.mutate { (numbers) in
					numbers.append(i)
				}
			}
		}
		
		group.wait()
		
		XCTAssertEqual(numbers.value.count, 100)
	}

    static var allTests = [
        ("testExample", testExample),
		("testAtomic", testAtomic),
    ]
}
