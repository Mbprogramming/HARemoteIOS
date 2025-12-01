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
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    
    var body: some View { 
        HStack {
            RemoteButtonGlass(remoteItem: command1, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds)
                .frame(width: 100, height: 100)
                .padding()
            if let command2 {
                RemoteButtonGlass(remoteItem: command2, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds)
                    .frame(width: 100, height: 100)
                    .padding()
            }
        }
    }
}

struct MainCommandsView: View {
    @Binding var mainCommands: [RemoteItem]
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        GlassEffectContainer {
            VStack {
                ForEach(Array(stride(from: 0, to: mainCommands.count, by: 2)), id: \.self) { i in
                    let command1 = mainCommands[i]
                    let command2 = (i + 1 < mainCommands.count) ? mainCommands[i + 1] : nil
                    MainCommandsViewLine(
                        command1: command1,
                        command2: command2,
                        currentRemoteItem: $currentRemoteItem,
                        remoteItemStack: $remoteItemStack,
                        commandIds: $commandIds
                    )
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var commandIds: [String] = []
    @Previewable @State var mainCommands: [RemoteItem] = []
    MainCommandsView(mainCommands: $mainCommands, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds)
}
