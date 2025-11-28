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
                                RemoteItemView(remoteItem: item, level: level + 1,
                                               height: height, currentRemoteItem: $currentRemoteItem,
                                               remoteItemStack: $remoteItemStack)
                                    .padding()
                            }
                            Spacer(minLength: height)
                        }
                    }
                }
            } else {
                RemoteButton(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack)
            }
        }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    var remoteItem: RemoteItem? = nil
    
    ListView(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack)
}
