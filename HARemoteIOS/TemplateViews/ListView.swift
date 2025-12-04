//
//  ListView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 25.11.25.
//

import SwiftUI

struct ListView: View {
    var remoteItem: RemoteItem?
    var level: Int = 0
    var height: CGFloat = 150
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    var body: some View {
        if remoteItem != nil {
            if level == 0 {
                ZStack {
                    BackgroundImage(remoteItem: remoteItem)
                    ScrollView {
                        VStack {
                            let height = mainWindowSize.height * 0.2
                            Spacer(minLength: height)
                            let children = remoteItem?.children ?? []
                            ForEach(children) { item in
                                if item.template == RemoteTemplate.Grid3x4Inline ||
                                    item.template == RemoteTemplate.Grid4x5Inline ||
                                    item.template == RemoteTemplate.Grid5x3Inline ||
                                    item.template == RemoteTemplate.Grid6x4Inline ||
                                    item.template == RemoteTemplate.Divider ||
                                    item.template == RemoteTemplate.Space {
                                    RemoteItemView(remoteItem: item, level: level + 1,
                                                   currentRemoteItem: $currentRemoteItem,
                                                   remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                                        .padding()
                                } else {
                                    RemoteItemView(remoteItem: item, level: level + 1,
                                                   currentRemoteItem: $currentRemoteItem,
                                                   remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                                    .frame(height: 150)
                                    .padding()
                                }
                            }
                            Spacer(minLength: height)
                        }
                    }
                }
            } else {
                RemoteButton(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
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
    
    ListView(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}

