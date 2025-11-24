//
//  Remote.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import Foundation

struct Remote: Decodable, Identifiable {
    let id: String
    let device: String?
    let zone: Zone?
    let description: String
    let icon: String?
    let remote: RemoteItem?
    let landscapeRemote: RemoteItem?
    let remoteConfig: String?
    //lastChange    [...]
    //defaultState    [...]
}
