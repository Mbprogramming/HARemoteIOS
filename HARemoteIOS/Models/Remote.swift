//
//  Remote.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import Foundation
import Observation

@Observable class Remote: Decodable, Identifiable, Equatable {
    static func == (lhs: Remote, rhs: Remote) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let device: String?
    let zone: Zone?
    let description: String
    let icon: String?
    let remote: RemoteItem?
    let landscapeRemote: RemoteItem?
    let remoteConfig: String?
    let lastChange: String?
    let defaultState: [StringStringTuple]?
    
    var lastChangeDate: Date? {
        if let ls = lastChange {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: ls) {
                return date
            }
        }
        return nil
    }
}
