//
//  MainCommandsView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 01.12.25.
//

import SwiftUI

struct MainCommandsViewLine: View {
    var command1: RemoteItem
    var command2: RemoteItem? = nil
    var command3: RemoteItem? = nil
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var isVisible: Bool
    @Binding var orientation: UIDeviceOrientation
    
    var body: some View {
        HStack {
            RemoteButtonGlass(remoteItem: command1, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, isVisible: $isVisible)
                .frame(width: 100, height: 100)
                .padding()
            if let command2 {
                RemoteButtonGlass(remoteItem: command2, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, isVisible: $isVisible)
                    .frame(width: 100, height: 100)
                    .padding()
            }
            if orientation == .landscapeLeft || orientation == .landscapeRight {
                if let command3 {
                    RemoteButtonGlass(remoteItem: command3, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, isVisible: $isVisible)
                        .frame(width: 100, height: 100)
                        .padding()
                }
            }
        }
    }
}

struct MainCommandsView: View {
    @Binding var mainCommands: [RemoteItem]
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var isVisible: Bool
    @Binding var orientation: UIDeviceOrientation
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        GlassEffectContainer {
            VStack {
                if orientation == .landscapeLeft || orientation == .landscapeRight {
                    ForEach(Array(stride(from: 0, to: mainCommands.count, by: 3)), id: \.self) { i in
                        let command1 = mainCommands[i]
                        let command2 = (i + 1 < mainCommands.count) ? mainCommands[i + 1] : nil
                        let command3 = (i + 2 < mainCommands.count) ? mainCommands[i + 2] : nil
                        MainCommandsViewLine(
                            command1: command1,
                            command2: command2,
                            command3: command3,
                            currentRemoteItem: $currentRemoteItem,
                            remoteItemStack: $remoteItemStack,
                            mainModel: $mainModel,
                            isVisible: $isVisible,
                            orientation: $orientation
                        )
                    }
                } else {
                    ForEach(Array(stride(from: 0, to: mainCommands.count, by: 2)), id: \.self) { i in
                        let command1 = mainCommands[i]
                        let command2 = (i + 1 < mainCommands.count) ? mainCommands[i + 1] : nil
                        MainCommandsViewLine(
                            command1: command1,
                            command2: command2,
                            command3: nil,
                            currentRemoteItem: $currentRemoteItem,
                            remoteItemStack: $remoteItemStack,
                            mainModel: $mainModel,
                            isVisible: $isVisible,
                            orientation: $orientation
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var mainCommands: [RemoteItem] = []
    @Previewable @State var isVisible: Bool = true
    @Previewable @State var orientation: UIDeviceOrientation = UIDeviceOrientation.portrait
    
    MainCommandsView(mainCommands: $mainCommands, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, isVisible: $isVisible, orientation: $orientation)
}
