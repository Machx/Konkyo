///
/// Copyright 2024 Colin Wheeler
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

public final class Debouncer {
	public typealias DebouncerAction = () -> Void

	public let oneShot: Bool
	private var fired = 0
	public let action: DebouncerAction
	public let delay: Double
	private var timer: DispatchSourceTimer
	private let queue: DispatchQueue
	private let cancelAfter: Int

	public init(oneShot: Bool = true,
				cancelAfter: Int = 0,
				delay: Double,
				queue: DispatchQueue = .global(qos: .background),
				_ eventHandler: @escaping DebouncerAction) {
		self.delay = delay
		self.action = eventHandler
		self.oneShot = oneShot
		self.queue = queue
		self.cancelAfter = cancelAfter
		self.timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
		self.timer.setEventHandler(handler: { [weak self] in
			guard let self else { return }
			if oneShot && (fired > 0) { return }
			action()
			guard oneShot else { return }
			fired += 1
			if fired >= cancelAfter {
				timer.cancel()
			}
		})
		self.timer.schedule(deadline: .now() + delay, repeating: oneShot ? 0.0 : delay)
		self.timer.resume()
	}

	public func reset() {
		if oneShot && (fired > 0) { return }
		timer.cancel()
		timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
		timer.setEventHandler(handler: { [weak self] in
			guard let self else { return }
			if oneShot && (fired > 0) { return }
			action()
			guard oneShot else { return }
			fired += 1
			if fired >= cancelAfter {
				timer.cancel()
			}
		})
		timer.schedule(deadline: .now() + delay, repeating: 0.0)
		timer.resume()
	}

	public func cancel() {
		timer.cancel()
	}
}
