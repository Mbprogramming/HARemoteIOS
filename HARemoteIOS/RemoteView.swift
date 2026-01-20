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
    @Binding var remoteStates: [HAState]
    @Binding var orientation: UIDeviceOrientation
    @Binding var disableScroll: Bool
    
    var body: some View {
        RemoteItemView(remoteItem: currentRemoteItem,
                       currentRemoteItem: $currentRemoteItem,
                       remoteItemStack: $remoteItemStack,
                       mainModel: $mainModel,
                       remoteStates: $remoteStates,
                       orientation: $orientation,
                       disableScroll: $disableScroll)
    }
}

#Preview {
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [HAState] = []
    @Previewable @State var orientation: UIDeviceOrientation = UIDeviceOrientation.portrait
    @Previewable @State var disableScroll: Bool = false
    
    RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
}
