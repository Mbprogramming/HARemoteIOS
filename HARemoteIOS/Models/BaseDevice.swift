//
//  IBaseDevice.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 19.01.26.
//

import Foundation

@Observable class BaseDevice: Decodable, Identifiable, Equatable, Hashable {
    static func == (lhs: BaseDevice, rhs: BaseDevice) -> Bool {
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
    let commands: [Command]?
    let states: [HAState]?
    //remoteFragments    [...]
    let icon: String?
    let tryToStartup: String?
    let startedUp: String?
}

