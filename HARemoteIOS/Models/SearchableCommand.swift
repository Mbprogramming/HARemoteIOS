//
//  SearchableCommand.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 27.01.26.
//

import Foundation

@Observable
final class SearchableCommand : Identifiable {
    var device: String?
    var command: String?
    var commandType: CommandType?
    var description: String?
    var id: String {
        (device ?? "") + "-" + (command ?? "")
    }

    init(device: String? = nil, command: String? = nil, commandType: CommandType? = nil, description: String? = nil) {
        self.device = device
        self.command = command
        self.commandType = commandType
        self.description = description
    }
}

