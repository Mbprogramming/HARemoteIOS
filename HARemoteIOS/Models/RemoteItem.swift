//
//  RemoteItem.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import Foundation
import Observation

@Observable class RemoteItem : Decodable, Identifiable {
    let id: String?
    let template: RemoteTemplate?
    let description: String?
    let children: [RemoteItem]?
    let device: String?
    let command: String?
    let stateDevice: String?
    let state: String?
    let stateIcon: String?
    let clientIcon: String?
    let showStateAndIcon: Bool?
    //stateColor    [...]
    let posX: Int?
    let posY: Int?
    let rowSpan: Int?
    let colSpan: Int?
    let icon: String?
    //min    [...]
    //max    [...]
    //step    [...]
    //greatStep    [...]
    //steps    [...]
    //lastChange    [...]
    //moreParameter    {...}
    //nullable: true
    //defaultConverter    [...]
    let gridHalfHeight: Bool?
    //commandMenuItems    [...]
    //stateList    [...]
    //gridBackgroundOpacity    [...]
    //gridBackgroundColor    [...]
    let backgroundImage: String?
    //buttonForm    ButtonFormEnum[...]
}
