import XCTest
@testable import Konkyo

public class IncrementOp: AsynchronousOperationBase {
	let queue = DispatchQueue(label: "com.thing")
	
	var value: Int = 0
	
	public init(value: Int) {
		super.init()
		self.value = value
	}
	
	public override func start() {
		isExecuting = true
		queue.async { [weak self] in
			guard let self = self else { return }
			self.value += 1
			self.isFinished = true
		}
	}
}

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
		
		for i in 1...10000 {
			queue.async(group:group) {
				numbers.mutate { (numbers) in
					numbers.append(i)
				}
			}
		}
		
		group.wait()
		
		XCTAssertEqual(numbers.value.count, 10000)
	}
	
	func testOperation() {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		
		let op = IncrementOp(value: 1)
		queue.addOperation(op)
		
		queue.waitUntilAllOperationsAreFinished()
		XCTAssertEqual(op.value, 2)
	}

    static var allTests = [
        ("testExample", testExample),
		("testAtomic", testAtomic),
    ]
}
