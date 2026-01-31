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
    var devices: [HABaseDevice] = []
    var searchableCommands: [SearchableCommand] = []
    var mainCommands: [RemoteItem] = []
    var commandIds: [CommandExecutionEntry] = []
    var remoteStates: [HAState] = []
    var automaticExecutions: [AutomaticExecutionEntry] = []
    var nonVisibleProperty: UUID = UUID()
    
    var currentRemote: Remote? = nil
    var currentRemoteItem: RemoteItem? = nil
    var remoteItemStack: [RemoteItem] = []
    
    public var automaticExecutionCount : Int {
        get {
            return self.automaticExecutions.count
        }
    }
    
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
    
    public var devicesWithStates: [HABaseDevice] {
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
    
    public var devicesWithCommands: [HABaseDevice] {
        return devices.filter { device in
            !(device.commands?.isEmpty ?? true)
        }
    }
    
    public func deviceCommandGroups(device: String?) -> [String] {
        if device == nil {
            return []
        }
        if let device = devices.first(where: {$0.id == device!}) {
            let temp2 = device.commands?.map(\.emptyGroup!) ?? []
            return Array(Set(temp2)).sorted(by: {$0 < $1})
        } else {
            return []
        }
    }
    
    public func deviceCommands(device: String?, group: String?) -> [HACommand] {
        if device == nil || group == nil {
            return []
        }
        if let device = devices.first(where: {$0.id == device!}) {
            return device.commands?.filter({$0.emptyGroup == group!}) ?? []
        } else {
            return []
        }
    }
    
    public func buildSearchableCommands() {
        searchableCommands = []
        for device in devices {
            for cmd in device.commands ?? [] {
                if cmd.commandType == .Push {
                    var name = device.name ?? " "
                    name += " "
                    if cmd.description != nil {
                        name += cmd.description!
                    } else {
                        name += cmd.id!
                    }
                    searchableCommands.append(SearchableCommand(device: device.id, command: cmd.id, commandType: .Push, description: name))
                }
            }
        }
    }
}
