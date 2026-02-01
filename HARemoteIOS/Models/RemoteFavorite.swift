//
//  RemoteFavorite.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 04.12.25.
//

import Foundation
import SwiftData

@Model
final class RemoteFavorite {
    var remoteId: String
    var user: String
    var server: String
    
    init(remoteId: String = "", user: String = "", server: String = "") {
        self.remoteId = remoteId
        self.user = user
        self.server = server
    }
}
