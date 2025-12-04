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
    
    init(remoteId: String = "") {
        self.remoteId = remoteId
        self.user = "mbprogramming@googlemail.com"
        self.server = "192.168.5.106:5000"
    }
}
