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
	
    func testVersion() {
		let version = Konkyo.Version()
		XCTAssertEqual(version.major, 0)
		XCTAssertEqual(version.minor, 1)
		XCTAssertEqual(version.bugfix, 0)
    }
	
	/// Make sure that Atomic mutation 
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
	
	/// Test Operation Access on isExecuting isFinished in AsyncOperationBase
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
