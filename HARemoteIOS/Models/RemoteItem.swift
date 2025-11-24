//
//  RemoteItem.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import Foundation

struct RemoteItem : Decodable, Identifiable {
    let id: String?
    //template    RemoteTemplate[...]
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
    //posX    [...]
    //posY    [...]
    //rowSpan    [...]
    //colSpan    [...]
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
    //gridHalfHeight    [...]
    //commandMenuItems    [...]
    //stateList    [...]
    //gridBackgroundOpacity    [...]
    //gridBackgroundColor    [...]
    //backgroundImage    [...]
    //buttonForm    ButtonFormEnum[...]
}
