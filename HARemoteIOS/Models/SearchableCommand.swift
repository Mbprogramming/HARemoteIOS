//
//  SearchableCommand.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 27.01.26.
//

import Foundation
import Observation

@Observable
final class SearchableCommand : Identifiable {
    var device: String?
    var command: String?
    var commandType: CommandType?
    var description: String?
    private let uuid = UUID()
    var id: String {
        let dev = device ?? ""
        let cmd = command ?? ""
        if dev.isEmpty && cmd.isEmpty {
            return uuid.uuidString
        }
        return "\(dev)-\(cmd)"
    }

    init(device: String? = nil, command: String? = nil, commandType: CommandType? = nil, description: String? = nil) {
        self.device = device
        self.command = command
        self.commandType = commandType
        self.description = description
    }
}

