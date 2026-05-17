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

import Combine
import Konkyo
import Testing

@Suite("ViewModel Protocol Tests")
struct ViewModelTests {

	/// Concrete ViewModel used only within these tests.
	final class CounterViewModel: ViewModel {
		@Published var count: Int = 0
	}

	@Test("ViewModel conformance implies ObservableObject")
	func testViewModelIsObservableObject() {
		let vm = CounterViewModel()
		#expect(vm is any ObservableObject)
	}

	@Test("@Published property on ViewModel triggers objectWillChange")
	func testPublishedPropertyTriggersObjectWillChange() async {
		let vm = CounterViewModel()

		await confirmation("objectWillChange fires when @Published property changes") { changed in
			var cancellables = Set<AnyCancellable>()
			vm.objectWillChange
				.sink { changed() }
				.store(in: &cancellables)

			vm.count = 42
			try? await Task.sleep(for: .milliseconds(50))
			withExtendedLifetime(cancellables) {}
		}
	}

	@Test("ViewModel is a reference type (class)")
	func testViewModelIsReferenceType() {
		let vm1 = CounterViewModel()
		let vm2 = vm1
		vm2.count = 10
		#expect(vm1.count == 10)
	}
}
