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

class MyTestClass {
	var myNum = 0
	
	init() {
		myNum = 0
	}
}

@Test("Test Creation initialization operator")
func testCreationInitializationOperator() async throws {
	let thing = MyTestClass() <- {
		$0.myNum = 5
	}
	#expect(thing.myNum == 5)
}

@Test("Operator returns the same instance it was given")
func testOperatorReturnsSameInstance() {
	let original = MyTestClass()
	let result = original <- { $0.myNum = 99 }
	#expect(result === original)
}

@Test("Operator works with a class that has no mutation")
func testOperatorWithNoMutation() {
	let thing = MyTestClass() <- { _ in }
	#expect(thing.myNum == 0)
}

@Test("Operator supports chaining configuration blocks via explicit parentheses")
func testOperatorChaining() {
	// The `<-` operator is in the default precedence group with no
	// associativity, so adjacent uses must be parenthesised.
	let thing = (MyTestClass() <- { $0.myNum = 5 }) <- { $0.myNum *= 2 }
	#expect(thing.myNum == 10)
}

@Test("Operator works with array types where the closure inspects the value")
func testOperatorWithArrayRead() {
	nonisolated(unsafe) var observedCount = -1
	let array = [1, 2, 3] <- { observedCount = $0.count }
	#expect(array == [1, 2, 3])
	#expect(observedCount == 3)
}

