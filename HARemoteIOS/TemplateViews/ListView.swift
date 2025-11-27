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
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
        
    var body: some View {
        if remoteItem != nil {
            if level == 0 {
                ZStack {
                    if remoteItem?.backgroundImage != nil {
                        let iconUrl: String = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=400&height=400&id=" + (remoteItem?.backgroundImage ?? "")
                        
                        AsyncImage(url: URL(string: iconUrl))
                    }
                    ScrollView {
                        VStack {
                            let children = remoteItem?.children ?? []
                            ForEach(children) { item in
                                RemoteItemView(remoteItem: item, level: level + 1,
                                               currentRemoteItem: $currentRemoteItem,
                                               remoteItemStack: $remoteItemStack)
                                    .padding()
                            }
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
