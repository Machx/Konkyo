import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KonkyoTests.allTests),
		testCase(AtomicTests.allTests),
    ]
}
#endif
