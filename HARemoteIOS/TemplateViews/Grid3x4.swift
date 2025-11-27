//
//  Grid3x4.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 27.11.25.
//

import SwiftUI

struct Grid3x4: View {
    var remoteItem: RemoteItem?
    var level: Int = 0
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    
    func buildItems() -> [[RemoteItem?]]{
        var result: [[RemoteItem?]] = []
        guard let children = remoteItem?.children else { return result }
        for y in 0...3 {
            var row: [RemoteItem?] = []
            for x in 0...2 {
                let item = children.filter { $0.posX == x && $0.posY == y }.first
                if item != nil {
                    row.append(item)
                } else {
                    row.append(nil)
                }
            }
            result.append(row)
        }
        return result
    }
    
    var body: some View {
        if remoteItem != nil {
            if level == 0 {
                ZStack {
                    BackgroundImage(remoteItem: remoteItem)
                    let temp = buildItems()
                    Grid {
                        ForEach (0..<4) { y in
                            GridRow {
                                ForEach (0..<3) { x in
                                    if let item = temp[y][x] {
                                        RemoteItemView(remoteItem: item, level: level + 1,
                                                       currentRemoteItem: $currentRemoteItem,
                                                       remoteItemStack: $remoteItemStack)
                                            .padding()
                                    } else {
                                        EmptyView()
                                    }
                                }
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
    var level: Int = 0
    
    Grid3x4(remoteItem: remoteItem, level: level, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack)
}
