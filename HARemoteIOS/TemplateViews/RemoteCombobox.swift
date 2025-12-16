//
//  RemoteCombobox.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 16.12.25.
//

import SwiftUI

struct RemoteCombobox: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    var body: some View {
        Menu {
            if let items = remoteItem?.steps {
                ForEach(items, id:\.self.item1) { item in
                    Button(item.item2 ?? "", action: {
                        let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: item.item1 ?? "")
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
    
    RemoteCombobox(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
