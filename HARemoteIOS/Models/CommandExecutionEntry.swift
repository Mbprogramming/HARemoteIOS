//
//  CommandExecutionEntry.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.01.26.
//

import Foundation
import Observation

@Observable class CommandExecutionEntry : Equatable, Identifiable {
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
    
    init(other: CommandExecutionEntry, received: Date) {
        self.id = other.id
        self.timeStamp = other.timeStamp
        self.received = received
        self.finished = nil
    }
    
    init (other: CommandExecutionEntry, finished: Date) {
        self.id = other.id
        self.timeStamp = other.timeStamp
        self.received = other.received
        self.finished = finished
    }
    
    var sendStr: String {
        return timeStamp.formatted(date: .numeric, time: .complete)
    }
    
    var receivedStr: String {
        return received == nil ? "-" : received!.formatted(date: .numeric, time: .complete)
    }
    
    var finishedStr: String {
        return finished == nil ? "-" : finished!.formatted(date: .numeric, time: .complete)
    }
}
