//
//  RemoteButtonCommandList.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.12.25.
//

import SwiftUI

struct RemoteButtonCommandList: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    var body: some View {
        Menu {
            if let items = remoteItem?.commandMenuItems {
                ForEach(items, id:\.self.description) { item in
                    Button(item.description ?? "", action: {
                        let id = HomeRemoteAPI.shared.sendCommand(device: item.device ?? "", command: item.command ?? "")
                        commandIds.append(id)
                    })
                }
            }
               } label: {
                   HStack {
                       let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
                       ButtonTextAndIcon(currentRemoteItem: remoteItem, currentState: currentState)
                   }
                   .frame(maxWidth: .infinity, maxHeight: .infinity)
               }
               .buttonStyle(.bordered)
        .tint(Color.primary)
        .buttonBorderShape(.roundedRectangle(radius: 10))
        .shadow(radius: 5)
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var commandIds: [String] = []
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    RemoteButtonCommandList(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
