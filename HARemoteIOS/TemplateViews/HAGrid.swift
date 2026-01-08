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
    var rows: Int = 4
    var columns: Int = 3
    var inline: Bool = false
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [IState]
    
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

    func buildSkipItems() -> [[Bool]] {
        var result: [[Bool]] = []
        guard let children = remoteItem?.children else { return result }
        var y = 0
        repeat {
            var row: [Bool] = []
            var x = 0
            repeat {
                let item = children.filter { $0.posX == x && $0.posY == y }.first
                if item != nil {
                    row.append(true)
                    let colSpan = item?.colSpan ?? 1
                    if colSpan > 1 {
                        var skipCounter = 1
                        repeat {
                            row.append(false)
                            x = x + 1
                            skipCounter = skipCounter + 1
                        } while skipCounter < colSpan
                    }
                } else {
                    row.append(true)
                }
                x = x + 1
            } while x < columns
            result.append(row)
            y = y + 1
        } while y < rows
        return result
    }

    func calcRowHeight() -> CGFloat {
        if inline {
            if let half = remoteItem?.gridHalfHeight, half {
                return calcColumnWidth()  / 2
            }
            return calcColumnWidth()
        }
        var result = (mainWindowSize.height - 100) / CGFloat(rows)
        result = result - 10
        return result
    }
    
    func calcColumnWidth() -> CGFloat {
        return mainWindowSize.width / CGFloat(columns) - 5
    }
    
    var body: some View {
        if remoteItem != nil {
            if level == 0 || inline {
                let rowHeight = calcRowHeight()
                let columnWidth = calcColumnWidth()
                // Precompute outside of the ViewBuilder
                let temp = buildItems()
                let temp2 = buildSkipItems()
                let rowCount = 0...rows - 1
                let colCount = 0...columns - 1
                let rowCountArray = Array(rowCount)
                let colCountArray = Array(colCount)

                ZStack {
                    BackgroundImage(remoteItem: remoteItem)
                    Grid (alignment: .topLeading) {
                            ForEach(rowCountArray, id: \.self) { y in
                                GridRow {
                                    ForEach(colCountArray, id: \.self) { x in
                                        if let item = temp[y][x] {
                                            if item.colSpan != nil && item.colSpan! > 1 {
                                                RemoteItemView(
                                                    remoteItem: item,
                                                    level: level + 1,
                                                    currentRemoteItem: $currentRemoteItem,
                                                    remoteItemStack: $remoteItemStack,
                                                    mainModel: $mainModel,
                                                    remoteStates: $remoteStates
                                                )
                                                .frame(height: rowHeight)
                                                .gridCellColumns(item.colSpan!)
                                            } else {
                                                RemoteItemView(
                                                    remoteItem: item,
                                                    level: level + 1,
                                                    currentRemoteItem: $currentRemoteItem,
                                                    remoteItemStack: $remoteItemStack,
                                                    mainModel: $mainModel,
                                                    remoteStates: $remoteStates
                                                )
                                                .frame(height: rowHeight)
                                            }
                                        } else {
                                            if temp2[y][x] == true {
                                                Rectangle()
                                                    .fill(.clear)
                                                    .frame(width: columnWidth, height: rowHeight)
                                                    .contentShape(Rectangle())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                }
            } else {
                RemoteButton(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
            }
        }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    var level: Int = 0
    var rows:Int = 4
    var columns:Int = 3
    
    HAGrid(remoteItem: remoteItem, level: level, rows: rows, columns: columns, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}

