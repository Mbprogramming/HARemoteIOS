//
//  Grid3x4.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 27.11.25.
//

import SwiftUI

struct HAGrid: View {
    var remoteItem: RemoteItem?
    var level: Int = 0
    var height: CGFloat = 50
    var rows: Int = 4
    var columns: Int = 3
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    func buildItems() -> [[RemoteItem?]]{
        var result: [[RemoteItem?]] = []
        guard let children = remoteItem?.children else { return result }
        for y in 0...rows - 1 {
            var row: [RemoteItem?] = []
            for x in 0...columns - 1 {
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
                    let rowCount = 0...rows - 1
                    let colCount = 0...columns - 1
                    Grid {
                        for y in rowCount {
                            GridRow {
                                for x in colCount {
                                    if let item = temp[y][x] {
                                        RemoteItemView(remoteItem: item, level: level + 1,
                                                       height: mainWindowSize.height / 4, currentRemoteItem: $currentRemoteItem,
                                                       remoteItemStack: $remoteItemStack)
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
    var rows:Int = 4
    var columns:Int = 3
    
    HAGrid(remoteItem: remoteItem, level: level, rows: rows, columns: columns, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack)
}
