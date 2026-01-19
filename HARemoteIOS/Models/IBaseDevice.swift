//
//  IBaseDevice.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 19.01.26.
//

import Foundation

@Observable class IBaseDevice: Decodable, Identifiable, Equatable, Hashable {
    static func == (lhs: IBaseDevice, rhs: IBaseDevice) -> Bool {
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
    //commands    [...]
    let states: [IState]?
    //remoteFragments    [...]
    let icon: String?
    let tryToStartup: String?
    let startedUp: String?
}

