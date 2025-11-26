//
//  ListView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 25.11.25.
//

import SwiftUI

struct ListView: View {
    private var remoteItemContent: RemoteItem?
    private var levelIntern: Int = 0
    
    init(remoteItem: RemoteItem? = nil, level: Int = 0) {
        remoteItemContent = remoteItem
        levelIntern = level
    }
    
    var body: some View {
        if remoteItemContent != nil {
            if levelIntern == 0 {
                ZStack {
                    if remoteItemContent?.backgroundImage != nil {
                        let iconUrl: String = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=400&height=400&id=" + (remoteItemContent?.backgroundImage ?? "")
                        
                        AsyncImage(url: URL(string: iconUrl))
                    }
                    ScrollView {
                        VStack {
                            let children = remoteItemContent?.children ?? []
                            ForEach(children) { item in
                                RemoteItemView(remoteItem: item, level: levelIntern + 1)
                                    .padding()
                            }
                        }
                    }
                }
            } else {
                RemoteButton(remoteItem: remoteItemContent)
            }
        }
    }
}

#Preview {
    ListView()
}
