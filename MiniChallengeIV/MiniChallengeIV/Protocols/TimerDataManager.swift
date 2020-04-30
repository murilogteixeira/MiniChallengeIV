//
//  TimerData.swift
//  MiniChallengeIV
//
//  Created by Caio Azevedo on 30/04/20.
//  Copyright © 2020 Murilo Teixeira. All rights reserved.
//

import Foundation

protocol TimerDataProtocol {
    var configTime: Int { get set }
    var focusTime: Int { get set }
    var lostFocusTime: Int { get set }
    var restTime: Int { get set }
    var timerStatus: TimerStatus { get set }
}

protocol TimerUpdates {
    func updateStatistics()
}
