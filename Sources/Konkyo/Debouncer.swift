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
	
	/// The Action that will be executed after uninterrupted by the delay.
	///
	/// This action is executed when the Debouncer has been uninterrupted by
	/// reset requests for the amount of time specified in the `delay` variable.
	/// This will be executed once and only once.
	public let action: DebouncerAction

	/// The Action that will be executed if the Debouncer is cancelled before the specified delay
	///
	/// If this is set then this action will be called anytime the Debouncer
	/// is reset or cancelled.
	public let cancelAction: DebouncerAction?

	/// The delay in seconds before the specified action is triggered.
	///
	/// This is a delay in seconds before the action is triggered. The Debouncer
	/// can be reset or cancelled before the action is triggered.
	public let delay: Double
	private var timer: DispatchSourceTimer
	private let queue: DispatchQueue

	public init(delay: Double,
				queue: DispatchQueue = .global(qos: .background),
				_ eventHandler: @escaping DebouncerAction,
				cancelAction: DebouncerAction? = nil) {
		self.delay = delay
		self.action = eventHandler
		self.cancelAction = cancelAction
		self.queue = queue
		self.timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
		self.timer.setEventHandler(handler: { [weak self] in
			guard let self else { return }
			action()
			timer.cancel()
		})
		self.timer.setCancelHandler(handler: { [weak self] in
			guard let self,
				  let cancelAction else { return }
			cancelAction()
		})
		self.timer.schedule(deadline: .now() + delay, repeating: 0.0)
		self.timer.resume()
	}

	public func reset() {
		timer.cancel()
		timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
		timer.setEventHandler(handler: { [weak self] in
			guard let self else { return }
			action()
			timer.cancel()
		})
		if let cancelAction {
			self.timer.setCancelHandler(handler: { [weak self] in
				guard let self,
					  let cancelAction = self.cancelAction else { return }
				cancelAction()
			})
		}
		timer.schedule(deadline: .now() + delay, repeating: 0.0)
		timer.resume()
	}

	public func cancel() {
		timer.cancel()
	}
}
