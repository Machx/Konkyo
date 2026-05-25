///
/// Copyright 2020 Colin Wheeler
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
@testable import Konkyo
import Testing

@Suite("Atomic API Tests")
struct AtomicTests {
	@Test("Test Atomic API")
	func testAtomic() {
		let numbers = Atomic<[Int]>([])

		let iterations = Int.random(in: 15_000...20_000)
		DispatchQueue.concurrentPerform(iterations: iterations) { (index) in
			numbers.mutate { (numbers) in
				numbers.append(index + 1)
			}
		}
		#expect(numbers.value.count == iterations)

		let totalValue = numbers.value.reduce(0, +)
		let expected = (iterations * (iterations + 1)) / 2
		#expect(totalValue == expected)
	}

	@Test("Empty mutate block")
	func testEmptyMutateBlock() {
		let value = Atomic(42)
		value.mutate { _ in }
		#expect(value.value == 42)
	}

	@Test("Concurrent read/write stress produces exact write count")
	func testReadWriteStress() {
		let counter = Atomic(0)
		let iterations = 10_000

		DispatchQueue.concurrentPerform(iterations: iterations) { i in
			if i % 2 == 0 {
				counter.mutate { $0 += 1 }
			} else {
				_ = counter.value
			}
		}

		// Exactly half the iterations (even indices 0..<iterations) increment.
		#expect(counter.value == iterations / 2)
	}

	@Test("Atomic works with non-integer types")
	func testAtomicWithStringType() {
		let text = Atomic("")
		text.mutate { $0 += "hello" }
		text.mutate { $0 += " world" }
		#expect(text.value == "hello world")
	}

	@Test("mutate closure receives the current value")
	func testMutateReceivesCurrentValue() {
		let number = Atomic(10)
		number.mutate { $0 *= 2 }
		#expect(number.value == 20)
	}
}
