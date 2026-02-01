//
//  IBaseDevice.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 19.01.26.
//

import Foundation
import Observation
@Observable class HABaseDevice: Decodable, Identifiable, Equatable, Hashable {
    static func == (lhs: HABaseDevice, rhs: HABaseDevice) -> Bool {
        guard lhs.id != nil || rhs.id != nil else { return false }
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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

