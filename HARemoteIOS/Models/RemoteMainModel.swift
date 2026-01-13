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
    var mainCommands: [RemoteItem] = []
    var commandIds: [CommandExecutionEntry] = []
    var remoteStates: [IState] = []
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
}
