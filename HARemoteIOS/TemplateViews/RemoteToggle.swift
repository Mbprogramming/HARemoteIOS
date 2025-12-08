//
//  RemoteToggle.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.12.25.
//

import SwiftUI

struct RemoteToggle: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    @State private var isEnabled = false
    @State private var isEnabled2 = true
    
    var body: some View {
        if let state = remoteStates.first(where: { $0.device == remoteItem?.stateDevice && $0.id == remoteItem?.state }) {
            VStack {
                if state.value == "True" {
                    Toggle("", isOn: $isEnabled2)
                        .labelsHidden()
                        .onChange(of: isEnabled2) {
                            let id = HomeRemoteAPI.shared.sendCommand(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "")
                            commandIds.append(id)
                        }
                } else {
                    Toggle("", isOn: $isEnabled)
                        .labelsHidden()
                        .onChange(of: isEnabled) {
                            let id = HomeRemoteAPI.shared.sendCommand(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "")
                            commandIds.append(id)
                        }
                }
                Text(remoteItem?.description ?? "")
                    .truncationMode(.middle)
                    .allowsTightening(true)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .font(.title)
            }
        }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var commandIds: [String] = []
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    RemoteToggle(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
