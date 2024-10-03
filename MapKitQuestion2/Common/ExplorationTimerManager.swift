//
//  ExplorationTimerManager.swift
//  MapKitQuestion2
//
//
import UIKit

class ExplorationTimerManager {

    private var timer: Timer?
    private var updateTimer: Timer?
    private var timeLimit: TimeInterval
    private weak var timerLabel: UILabel?
    private var timeLimitReachedCallback: (() -> Void)?
    
    init(timeLimit: TimeInterval, timerLabel: UILabel?, timeLimitReachedCallback: @escaping () -> Void) {
        self.timeLimit = timeLimit
        self.timerLabel = timerLabel
        self.timeLimitReachedCallback = timeLimitReachedCallback
    }

    // Starts the exploration timer and updates the label every second
    func startExplorationTimer() {
        // Invalidate any previous timers
        timer?.invalidate()
        updateTimer?.invalidate()

        // Start a new countdown timer
        timer = Timer.scheduledTimer(timeInterval: timeLimit, target: self, selector: #selector(timeLimitReached), userInfo: nil, repeats: false)

        // Start a new timer to update the label every second
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] updateTimer in
            guard let self = self else { return }
            self.timeLimit -= 1
            self.updateTimerLabel()
            if self.timeLimit <= 0 {
                updateTimer.invalidate()
                self.timeLimitReached()
            }
        }
    }

    @objc private func timeLimitReached() {
        timeLimitReachedCallback?()
    }

    // Resets the timer with a new time limit
    func resetTimer(newTimeLimit: TimeInterval) {
        self.timeLimit = newTimeLimit
        updateTimerLabel()
    }

    // Updates the timer label with the remaining time
    private func updateTimerLabel() {
        timerLabel?.text = "Time Remaining: \(Int(timeLimit)) seconds"
    }

    // Invalidates the current timer
    func invalidateTimers() {
        timer?.invalidate()
        updateTimer?.invalidate()
    }
}
