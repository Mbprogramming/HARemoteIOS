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
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [IState]
    @Binding var orientation: UIDeviceOrientation
    
    var body: some View {
        RemoteItemView(remoteItem: currentRemoteItem,
                       currentRemoteItem: $currentRemoteItem,
                       remoteItemStack: $remoteItemStack,
                       mainModel: $mainModel,
                       remoteStates: $remoteStates,
                       orientation: $orientation)
    }
}

#Preview {
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [IState] = []
    @Previewable @State var orientation: UIDeviceOrientation = UIDeviceOrientation.portrait
    
    RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation)
}
