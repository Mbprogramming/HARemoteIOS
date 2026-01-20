//
//  AddStateChangeAutomaticExecutionData.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 20.01.26.
//

import Foundation

class AddStateChangeAutomaticExecutionData: Codable {
    var stateDevice: String
    var commandDevice: String
    var state: String
    var command: String
    var operation: String
    var limit: String
    var parameter: String?
    
    init(stateDevice: String, commandDevice: String, state: String, command: String, operation: String, limit: String, parameter: String?) {
        self.stateDevice = stateDevice
        self.commandDevice = commandDevice
        self.state = state
        self.command = command
        self.operation = operation
        self.limit = limit
        self.parameter = parameter
    }
}
