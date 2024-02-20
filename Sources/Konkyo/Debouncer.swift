//
//  File.swift
//  
//
//  Created by Colin Wheeler on 2/19/24.
//

import Foundation

public final class Debouncer {
	public typealias DebouncerAction = () -> Void

	public let oneShot: Bool
	private var fired = false
	public let action: DebouncerAction
	public let delay: Double

	private var timer: DispatchSourceTimer

	public init(oneShot: Bool = false,
				delay: Double,
				_ eventHandler: @escaping DebouncerAction) {
		self.delay = delay
		self.action = eventHandler
		self.oneShot = oneShot
		self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
		self.timer.setEventHandler(handler: { [weak self] in
			guard let self else { return }
			if self.oneShot && self.fired { return }
			self.action()
			guard self.oneShot else { return }
			self.fired = true
		})
		self.timer.schedule(deadline: .now() + delay, repeating: 0.0)
		self.timer.resume()
	}

	public func execute() {
		if oneShot && fired { return }
		timer.cancel()
		timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
		timer.setEventHandler(handler: { [weak self] in
			guard let self else { return }
			if oneShot && fired { return }
			action()
			guard oneShot else { return }
			fired = true
		})
		timer.schedule(deadline: .now() + delay, repeating: 0.0)
		timer.resume()
	}
}
