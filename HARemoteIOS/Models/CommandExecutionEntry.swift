//
//  CommandExecutionEntry.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.01.26.
//

import Foundation
import Observation

@Observable class CommandExecutionEntry : Equatable {
    static func == (lhs: CommandExecutionEntry, rhs: CommandExecutionEntry) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var timeStamp: Date
    var received: Date?
    var finished: Date?
    
    init(id: String) {
        self.id = id
        self.timeStamp = Date()
        self.received = nil
        self.finished = nil
    }
}
