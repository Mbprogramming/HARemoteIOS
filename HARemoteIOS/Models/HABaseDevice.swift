//
//  HABaseDevice.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 19.01.26.
//

import Foundation
import Observation
@Observable class HABaseDevice: Decodable, Identifiable, Equatable, Hashable {
    static func == (lhs: HABaseDevice, rhs: HABaseDevice) -> Bool {
        if let lid = lhs.id, let rid = rhs.id {
            return lid == rid
        }
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        if let id = id {
            hasher.combine(id)
        } else {
            hasher.combine(ObjectIdentifier(self))
        }
    }

    let id: String?
    let name: String?
    //state    DeviceState[...]
    let config: String?
    let autoLoad: Bool?
    let autoStart: Bool?
    let commands: [HACommand]?
    let states: [HAState]?
    //remoteFragments    [...]
    let icon: String?
    let tryToStartup: String?
    let startedUp: String?
}

