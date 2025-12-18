//
//  RemoteButton.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 25.11.25.
//

import SwiftUI

struct RemoteButton: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    var body: some View {
        RemoteBaseButton(remoteItem: remoteItem, action: {
            if remoteItem?.template == RemoteTemplate.List
                || remoteItem?.template == RemoteTemplate.Wrap
                || remoteItem?.template == RemoteTemplate.Grid3X4
                || remoteItem?.template == RemoteTemplate.Grid4X5
                || remoteItem?.template == RemoteTemplate.Grid5x3 {
                guard let children = remoteItem?.children else { return }
                if children.count > 0 {
                    // Do not shadow the binding; unwrap into a different name
                    guard let current = currentRemoteItem else { return }
                    remoteItemStack.append(current)
                    guard let next = remoteItem else { return }
                    currentRemoteItem = next
                }
            }
            if remoteItem?.template == RemoteTemplate.Command {
                let id = HomeRemoteAPI.shared.sendCommand(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "")
                commandIds.append(id)
            }
        }, actionDeferred: { (date: Date, type: Int) in
            if type == 0 {
                let hour = Calendar.current.component(.hour, from: date)
                let minute = Calendar.current.component(.minute, from: date)
                let delay = (hour * 60 * 60) + (minute * 60)
                let id = HomeRemoteAPI.shared.sendCommandDeferred(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", delay: delay, cyclic: false)
                commandIds.append(id)
            } else {
                if type == 1 {
                    let hour = Calendar.current.component(.hour, from: date)
                    let minute = Calendar.current.component(.minute, from: date)
                    let delay = (hour * 60 * 60) + (minute * 60)
                    let id = HomeRemoteAPI.shared.sendCommandDeferred(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", delay: delay, cyclic: true)
                    commandIds.append(id)
                }
            }
        }, remoteStates: $remoteStates)
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var commandIds: [String] = []
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    RemoteButton(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
