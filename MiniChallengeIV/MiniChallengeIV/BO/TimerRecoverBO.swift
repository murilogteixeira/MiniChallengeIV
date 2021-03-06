//
//  TimerRecoverBO.swift
//  MiniChallengeIV
//
//  Created by Caio Azevedo on 05/05/20.
//  Copyright © 2020 Murilo Teixeira. All rights reserved.
//

import Foundation

enum BackgroundStatus {
    case lockScreen
    case homeScreen
}

class TimeRecoverBO {
    var enterBackgroundInstant: Date?
    var returnFromBackgroundInstant: Date!
    
    var backgroundStatus: BackgroundStatus?

    var timer: TimeTrackerBO

    init(timer: TimeTrackerBO) {
        self.timer = timer
    }

    func enterbackground(){
        if timer.state == TimeTrackerState.focus {
            /// Save the moment that enterBackground
            self.enterBackgroundInstant = Date()
            
            print("EnterBackground Instant: \(enterBackgroundInstant!)")
            
        } else if timer.state == TimeTrackerState.pause {
            /// Local Notification with rest Time as delay
        }
    }

    func returnFromBackground(){
        guard let backgroundInstant = self.enterBackgroundInstant else { return }
        
        let timeInBackground = backgroundTimeRecover(backgroundInstant: backgroundInstant)
        
        /// Handle Timer State
        if timer.state == .focus{
            let changeCicle =  updateTimerAtributesWhenFocus(lostFocusTime: timeInBackground)
            
            if changeCicle {
                /// Reset timer
                timer.countDown = 0
            }
           
        } else if timer.state == .pause{
            let changeCicle = updateTimerAtributesWhenPause(restInBackgrund: timeInBackground)
            
            if changeCicle {
                // Reset timer
                timer.countDown = 0
            }
        }
    }

    /// Description: Function to recover and update the timer or the esttistics
    func backgroundTimeRecover(backgroundInstant: Date) -> Int{
        self.returnFromBackgroundInstant = Date()
        
        /// Get the time the user has been out of the app
        let timeInBackground = Int(backgroundInstant.distance(to: self.returnFromBackgroundInstant))
        
        print("Came Back after : \(timeInBackground)")
        
        return timeInBackground
    }

    func updateTimerAtributesWhenFocus(lostFocusTime: Int) -> Bool{
        let currentTime = lostFocusTime + timer.lostFocusTime + timer.focusTime
        
        /// If the user has been out more than the time he configured, change cicle of Timer
        if currentTime < timer.configTime * 60 {
            /// Update lost focus time from timer with the value calculate when returns from background and the configured Time isnt over
            if self.backgroundStatus == BackgroundStatus.homeScreen {
                timer.lostFocusTime += (lostFocusTime)
                timer.qtdLostFocus += 1
            } else {
                timer.focusTime += lostFocusTime
            }
            
            timer.countDown -= lostFocusTime
            
            return false
        } else {
            if self.backgroundStatus == BackgroundStatus.homeScreen {
                /// Update Timer - Lost Focus Time
                timer.lostFocusTime = timer.configTime * 60 - timer.focusTime
                timer.qtdLostFocus += 1
            } else {
                timer.focusTime = timer.configTime * 60 - timer.lostFocusTime
            }
            timer.countDown = 0
            return true
        }
    }

    func updateTimerAtributesWhenPause(restInBackgrund: Int) -> Bool{
        let currentRestTime = restInBackgrund + timer.restTime
        
        /// If the user has been out more than the time he configured, change cicle of Timer
        if currentRestTime < timer.configTime * 60 {
            /// Update Atributes
            timer.restTime += restInBackgrund
            timer.countDown -= restInBackgrund
            
            return false
        } else {
            timer.restTime = timer.configTime * 60
            
            return true
        }
    }
}
