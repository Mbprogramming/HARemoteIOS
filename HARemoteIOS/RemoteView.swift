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
    
    var body: some View {
        RemoteItemView(remoteItem: currentRemoteItem,
        currentRemoteItem: $currentRemoteItem,
        remoteItemStack: $remoteItemStack)
    }
}

#Preview {
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    
    RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack)
}
