//
//  RemoteMainModel.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 07.01.26.
//

import Foundation
import Observation

@Observable class RemoteMainModel {
    var zones: [Zone] = []
    var remotes : [Remote] = []
    var mainCommands: [RemoteItem] = []
    var commandIds: [CommandExecutionEntry] = []
    var remoteStates: [IState] = []
    var automaticExecutions: [AutomaticExecutionEntry] = []

    var currentRemote: Remote? = nil
    var currentRemoteItem: RemoteItem? = nil
    var remoteItemStack: [RemoteItem] = []
    
    public func executeCommand(id: String) {
        let cmd = CommandExecutionEntry(id: id)
        commandIds.append(cmd)
    }

    public func receiveExecution(id: String) {
        if let item = commandIds.first(where: { $0.id == id }){
            item.received = Date()
        }
    }
    public func finishExecution(id: String) {
        if let index = commandIds.firstIndex(of: CommandExecutionEntry(id: id)) {
            _ = commandIds.remove(at: index)
        }
    }
    
    public func existId(id: String) -> Bool {
        if let _ = commandIds.first(where: { $0.id == id }){
            return true
        }
        return false
    }
}
