//
//  SingleTimerController.swift
//  Timerity
//
//  Created by Curt Clifton on 12/29/14.
//  Copyright (c) 2014 curtclifton.net. All rights reserved.
//

import WatchKit
import TimerityData

class SingleTimerController {
    var timer: TimerInformation?
    private var timerUpdateCallbackID: TimerChangeCallbackID?
    private var isActive = true // we assume that we're initially active so that loading into an already loaded UI causes an update
    private var needsUpdate = false
    
    // outlets
    var nameLabel: WKInterfaceLabel
    var totalTimeLabel: WKInterfaceLabel
    var countdownTimer: WKInterfaceTimer
    var button: WKInterfaceButton?
    
    init(nameLabel: WKInterfaceLabel, totalTimeLabel: WKInterfaceLabel, countdownTimer: WKInterfaceTimer, button: WKInterfaceButton? = nil) {
        self.nameLabel = nameLabel
        self.totalTimeLabel = totalTimeLabel
        self.countdownTimer = countdownTimer
        self.button = button
    }
    
    //MARK: - Package API
    func willActivate() {
        isActive = true
        _updateIfNeeded()
    }
    
    func didDeactivate() {
        isActive = false
    }
    
    // CCC, 12/29/2014. Maybe this should be setTimer. Is there any advantage in exposing the timerID? Why not just pass around timers?
    func setTimerID(timerID: String) {
        _clearCurrentTimerCallback()
        let registrationResult = timerDB.registerCallbackForTimer(identifier: timerID) { newTimer in
            self.timer = newTimer
            self.needsUpdate = true
            self._updateIfNeeded()
        }
        switch registrationResult {
        case .left(let callbackIDBox):
            timerUpdateCallbackID = callbackIDBox.unwrapped
            break;
        case .right(let errorBox):
            println("Error getting information for timer: \(errorBox.unwrapped)")
            timer = nil
            break;
        }
    }
    
    func buttonPressed() {
        if var timer = self.timer {
            switch timer.state {
            case .Active(fireDate: let fireDate):
                countdownTimer.stop() // the countdown will be removed by the callback, but lets not let the count drop below the cached time remaining
                timer.pause()
                timerDB.updateTimer(timer) // triggers a callback that updates the UI
                let startCommand = TimerCommand.Start // CCC, 12/30/2014. should the actual start command be sent by timerDB? Seems likely. Then the callback should be triggered when the main app updates the file on disk, prompting the DB to reload thanks to file coordination.
                startCommand.send(timer)
                break;
            case .Paused(timeRemaining: let timeRemaining):
                timer.resume()
                timerDB.updateTimer(timer) // triggers a callback that updates the UI
                let startCommand = TimerCommand.Start // CCC, 12/30/2014. should the actual start command be sent by timerDB? Seems likely. Then the callback should be triggered when the main app updates the file on disk, prompting the DB to reload thanks to file coordination.
                startCommand.send(timer)
                break;
            case .Inactive:
                timer.start()
                timerDB.updateTimer(timer) // triggers a callback that updates the UI
                let startCommand = TimerCommand.Start // CCC, 12/30/2014. should the actual start command be sent by timerDB? Seems likely. Then the callback should be triggered when the main app updates the file on disk, prompting the DB to reload thanks to file coordination.
                startCommand.send(timer)
                break;
            }
        }
    }
    
    func clearTimerID() {
        _clearCurrentTimerCallback()
        timer = nil
    }
    
    //MARK: - Private API
    private func _updateIfNeeded() {
        if !needsUpdate || !isActive {
            return;
        }
        if let timer = self.timer {
            println("yay! \(timer)");
            nameLabel.setText(timer.name)
            switch timer.state {
            case .Active(fireDate: let fireDate):
                countdownTimer.setDate(fireDate)
                countdownTimer.start()
                totalTimeLabel.setHidden(true)
                countdownTimer.setHidden(false)
                button?.setTitle(NSLocalizedString("Pause", comment: "pause button label"))
                button?.setHidden(false)
                break;
            case .Paused(timeRemaining: let timeRemaining):
                totalTimeLabel.setText(timeRemaining.description) // CCC, 12/23/2014. add function for formatting a duration nicely
                totalTimeLabel.setHidden(false)
                countdownTimer.setHidden(true)
                button?.setTitle(NSLocalizedString("Resume", comment: "resume button label"))
                button?.setHidden(false)
                break;
            case .Inactive:
                totalTimeLabel.setText(timer.duration.description) // CCC, 12/23/2014. add function for formatting a duration nicely
                totalTimeLabel.setHidden(false)
                countdownTimer.setHidden(true)
                button?.setTitle(NSLocalizedString("Start", comment: "start button label"))
                button?.setHidden(false)
                break;
            }
        } else {
            println("Eep, no timer")
            nameLabel.setText(NSLocalizedString("Missing timer", comment: "missing timer row label"))
            totalTimeLabel.setHidden(true)
            countdownTimer.setHidden(true)
            button?.setHidden(true)
        }
        needsUpdate = false
    }

    private func _clearCurrentTimerCallback() {
        if let currentCallbackID = timerUpdateCallbackID {
            timerDB.unregisterCallback(identifier: currentCallbackID)
            timerUpdateCallbackID = nil
        }
    }
}