//
//  RemoteHistoryEntry.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 04.12.25.
//

import Foundation
import SwiftData

@Model
final class RemoteHistoryEntry {
    var lastUsed: Date
    var remoteId: String
    var user: String
    var server: String
    
    init(remoteId: String = "", user: String = "", server: String = "") {
        self.lastUsed = Date()
        self.remoteId = remoteId
        self.user = user
        self.server = server
    }
}
