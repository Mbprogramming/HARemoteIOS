//
//  RemoteView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct RemoteView: View {
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    var body: some View {
        RemoteItemView(remoteItem: currentRemoteItem,
        currentRemoteItem: $currentRemoteItem,
        remoteItemStack: $remoteItemStack,
        commandIds: $commandIds,
        remoteStates: $remoteStates)
    }
}

#Preview {
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var commandIds: [String] = []
    @Previewable @State var remoteStates: [IState] = []
    
    RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
