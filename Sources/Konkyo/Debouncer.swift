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

/// Debouncer is a wrapper for functionality around a timer event handler with reset functionality.
///
/// Debouncer wraps a dispatch source timer with reset functionality. That is that it can be reset
/// over and over, until the event actually triggers. Each armed timer executes the event function
/// at most once: after it fires, the debouncer is idle and the action will not run again on its own.
/// Calling `reset()` after the action has fired arms a new timer, so the action will fire again.
/// Anytime a pending timer is reset or cancelled before it fires, the cancel block will be executed.
/// Unlike the event handler, the cancel handler will be executed anytime a pending timer is reset.
/// The cancel handler is not executed for a timer whose action has already fired.
///
/// The queue used to dispatch the event/cancel handlers **must be serial**. Passing a
/// concurrent queue (e.g. any `DispatchQueue.global(qos:)`) results in undefined behavior
/// — the event and cancel handlers may fire more than once or in an unexpected order.
/// `DispatchQueue.main` and any queue created without `.concurrent` attributes are valid.
/// If no queue is supplied, the Debouncer creates its own private serial queue.
public final class Debouncer {
	public typealias DebouncerAction = () -> Void
	
	/// The Action that will be executed after uninterrupted by the delay.
	///
	/// This action is executed when the Debouncer has been uninterrupted by
	/// reset requests for the amount of time specified in the `delay` variable.
	/// This will be executed at most once per armed timer. It fires again only if
	/// `reset()` is called after it has fired, which arms a new timer.
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
	public let delay: TimeInterval

	/// The object responsible for scheduling the action to take place after a delay.
	///
	/// Access is guarded by `timerMutex`, since `reset()` and `cancel()` can be called from any thread.
	private var timer: DispatchSourceTimer
	private let timerMutex = Mutex()

	/// The Queue that the event and cancel handlers will be dispatched on.
	private let queue: DispatchQueue
	
	/// Initializes the Debouncer and arms its first timer.
	/// - Parameters:
	///   - delay: The delay in seconds that the event handler will be executed after.
	///   - queue: A **serial** queue that the event and cancel handlers will be dispatched onto.
	///     Defaults to a private serial queue created for this Debouncer instance.
	///   - eventHandler: The action that will take place after `delay` unless reset or cancelled.
	///   - cancelAction: When a debouncer is cancelled this will be called in response to that event.
	public init(delay: TimeInterval,
				queue: DispatchQueue = DispatchQueue(label: "Konkyo.Debouncer", qos: .background),
				_ eventHandler: @escaping DebouncerAction,
				cancelAction: DebouncerAction? = nil) {
		self.delay = delay
		self.action = eventHandler
		self.cancelAction = cancelAction
		self.queue = queue
		self.timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
		scheduleTimer(self.timer)
	}
	
	/// Resets the Debouncer by cancelling the previous timer & starting a new one.
	///
	/// This cancels the previous timer source, and sets up a new one. When the previous
	/// timer is cancelled, this will call the cancel handler if that is set.
	public func reset() {
		timerMutex.withLock {
			timer.cancel()
			timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
			scheduleTimer(timer)
		}
	}
	
	private func scheduleTimer(_ source: DispatchSourceTimer) {
		let didFireEvent = Atomic(false)
		source.setEventHandler(handler: { [weak self, weak source] in
			guard let self else { return }
			didFireEvent.mutate { $0 = true }
			action()
			// Cancel the source that fired, not `self.timer`, which a concurrent
			// `reset()` may already have replaced with a fresh timer.
			source?.cancel()
		})
		if let cancelAction {
			source.setCancelHandler(handler: { [weak self] in
				guard self != nil else { return }
				guard !didFireEvent.value else { return }
				cancelAction()
			})
		}
		source.schedule(deadline: .now() + delay, repeating: 0.0)
		source.resume()
	}
	
	/// Only cancels the timer, but does not reset it or start a new timer.
	///
	/// Unlike reset, this only cancels the timer, but does not reset it. Making it
	/// possible to start it again in the future.
	public func cancel() {
		timerMutex.withLock { timer.cancel() }
	}
}
