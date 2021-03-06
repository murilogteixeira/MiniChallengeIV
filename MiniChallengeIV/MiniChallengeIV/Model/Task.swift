//
//  TaskBean.swift
//  MiniChallengeIV
//
//  Created by Carlos Fontes on 30/04/20.
//  Copyright © 2020 Murilo Teixeira. All rights reserved.
//

import Foundation

/// Representation structure of database entities
struct Task {
    var id: UUID
    var description: String
    var state: Bool = false
    var taskCD: TaskCD? = nil
    var createdAt: Date

//    var project: ProjectBean
    
//    init(uuid: UUID, description: String, state: Bool) {
//        self.uuid = uuid
//        self.description = description
//        self.state = state
//    }
//    
//    init(uuid: UUID, description: String, state: Bool, taskCD: TaskCD) {
//        self.uuid = uuid
//        self.description = description
//        self.state = state
//        self.taskCD = taskCD
//    }
}
