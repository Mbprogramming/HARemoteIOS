//
//  RemoteMainModel.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 07.01.26.
//

import Foundation
import Observation

@Observable class RemoteMainModel : Equatable {
    static func == (lhs: RemoteMainModel, rhs: RemoteMainModel) -> Bool {
        return lhs.nonVisibleProperty == rhs.nonVisibleProperty
    }
    
    var zones: [Zone] = []
    var remotes : [Remote] = []
    var devices: [BaseDevice] = []
    var mainCommands: [RemoteItem] = []
    var commandIds: [CommandExecutionEntry] = []
    var remoteStates: [HAState] = []
    var automaticExecutions: [AutomaticExecutionEntry] = []
    var nonVisibleProperty: UUID = UUID()
    
    var currentRemote: Remote? = nil
    var currentRemoteItem: RemoteItem? = nil
    var remoteItemStack: [RemoteItem] = []
    
    public func executeCommand(id: String) {
        let cmd = CommandExecutionEntry(id: id)
        commandIds.append(cmd)
    }
    
    public func receiveExecution(id: String) {
        if let item = commandIds.first(where: { id.starts(with: $0.id) }){
            item.received = Date()
        }
    }
    public func finishExecution(id: String) {
        if let item = commandIds.first(where: { id.starts(with: $0.id)}){
            item.finished = Date()
        }
    }
    
    public func existId(id: String) -> Bool {
        if let _ = commandIds.first(where: { id.starts(with: $0.id) }){
            return true
        }
        return false
    }
    
    public var devicesWithStates: [BaseDevice] {
        return devices.filter { device in
            !(device.states?.isEmpty ?? true)
        }
    }
    
    public func deviceStates(device: String?) -> [HAState] {
        if device == nil {
            return []
        }
        if let device = devices.first(where: {$0.id == device!}) {
            return device.states ?? []
        } else {
            return []
        }
    }
    
    public var devicesWithCommands: [BaseDevice] {
        return devices.filter { device in
            !(device.commands?.isEmpty ?? true)
        }
    }
    
    public func deviceCommandGroups(device: String?) -> [String] {
        if device == nil {
            return []
        }
        if let device = devices.first(where: {$0.id == device!}) {
            let temp1 = device.commands?.filter({$0.group != nil}) ?? []
            let temp2 = temp1.map(\.group!)
            return Array(Set(temp2))
        } else {
            return []
        }
    }
    
    public func deviceCommands(device: String?, group: String?) -> [Command] {
        if device == nil || group == nil {
            return []
        }
        if let device = devices.first(where: {$0.id == device!}) {
            return device.commands?.filter({$0.group == group!}) ?? []
        } else {
            return []
        }
    }
}
