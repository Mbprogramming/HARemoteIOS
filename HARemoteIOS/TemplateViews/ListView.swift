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
    @State var rows: [ListViewRow] = []
    @State var cols: Int = 1
    @State var w: CGFloat = 150
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [IState]
    
    init(
        remoteItem: RemoteItem? = nil,
        level: Int = 0,
        height: CGFloat = 150,
        currentRemoteItem: Binding<RemoteItem?>,
        remoteItemStack: Binding<[RemoteItem]>,
        mainModel: Binding<RemoteMainModel>,
        remoteStates: Binding<[IState]>
    ) {
        self.remoteItem = remoteItem
        self.level = level
        self.height = height
        self._currentRemoteItem = currentRemoteItem
        self._remoteItemStack = remoteItemStack
        self._mainModel = mainModel
        self._remoteStates = remoteStates
    }
    
    private func buildRows() {
        rows = []
        cols = remoteItem?.colSpan ?? 1
        if cols < 1 {
            cols = 1
        }
        w = (mainWindowSize.width / CGFloat(cols))
        if let children = remoteItem?.children {
            let count = children.count
            if count == 0 {
                return
            }
            let indices = 0..<(count)
            var current = ListViewRow()
            var currentCol = 0
            for index in indices {
                let item = children[index]
                if item.template == RemoteTemplate.Grid3x4Inline ||
                    item.template == RemoteTemplate.Grid4x5Inline ||
                    item.template == RemoteTemplate.Grid5x3Inline ||
                    item.template == RemoteTemplate.Grid6x4Inline ||
                    item.template == RemoteTemplate.Divider ||
                    item.template == RemoteTemplate.EmptyListItem ||
                    item.template == RemoteTemplate.Space {
                    if current.count > 0 {
                        rows.append(current)
                        current = ListViewRow()
                    }
                    current.items.append(item)
                    rows.append(current)
                    current = ListViewRow()
                } else {
                    current.items.append(item)
                    currentCol = currentCol + 1
                    if currentCol == cols {
                        rows.append(current)
                        current = ListViewRow()
                        currentCol = 0
                    }
                }
            }
        }
    }
    
    private func buildRow(row: ListViewRow) -> some View {
        return HStack {
            ForEach(row.items as! [RemoteItem]) { item in
                if item.template == RemoteTemplate.Grid3x4Inline ||
                    item.template == RemoteTemplate.Grid4x5Inline ||
                    item.template == RemoteTemplate.Grid5x3Inline ||
                    item.template == RemoteTemplate.Grid6x4Inline ||
                    item.template == RemoteTemplate.Divider ||
                    item.template == RemoteTemplate.Space {
                    RemoteItemView(remoteItem: item, level: level + 1,
                                   currentRemoteItem: $currentRemoteItem,
                                   remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                } else {
                    if item.template == RemoteTemplate.EmptyListItem {
                        EmptyView()
                    } else {
                        RemoteItemView(remoteItem: item, level: level + 1,
                                       currentRemoteItem: $currentRemoteItem,
                                       remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                        .frame(width: w, height: 150)
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
    }
    
    var body: some View {
        if remoteItem != nil {
            if level == 0 {
                ZStack {
                    BackgroundImage(remoteItem: remoteItem)
                    ScrollView {
                        let height = mainWindowSize.height * 0.2
                        VStack(alignment: .leading) {
                            Spacer(minLength: height)
                            ForEach(rows) { row in
                                buildRow(row: row)
                            }
                            Spacer(minLength: height)
                        }
                    }
                }
                .onChange(of: remoteItem) {
                    buildRows()
                }
                .onAppear {
                    buildRows()
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
    
    ListView(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}

