//
//  TouchView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 14.01.26.
//

import SwiftUI

struct TouchView: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [IState]
    @Binding var disableScroll: Bool
    
    @State var selectedMode: Int = 0
    
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    func calcRowHeight() -> CGFloat {
        return calcColumnWidth()
    }
    
    func calcColumnWidth() -> CGFloat {
        return mainWindowSize.width / 3 - 5
    }
    
    func buildIcons() -> [String?] {
        // Collect icon-related values from moreParameter
        guard let params = remoteItem?.moreParameter else { return [] }

        // If keys like "Icon_0", "Icon_1", ... are expected, gather them in order
        var icons: [String?] = []

        for index in 0..<9 {
            if let value = params["Icon_\(index)"] {
                icons.append(value)
            } else {
                icons.append(nil)
            }
        }

        return icons
    }
    
    func buildRemoteItems(icons: [String?]) -> [RemoteItem?] {
        guard let params = remoteItem?.moreParameter else { return [] }
        
        var cmds: [RemoteItem?] = []
        for index in 0..<9 {
            switch index {
            case 1:
                if let value = params["SwipeUp"] {
                    let parts = value.split(separator: ";")
                    if parts.count >= 2 {
                        cmds.append(RemoteItem(id: "SwipeUp", template: RemoteTemplate.Command, description: "Up", device: String(parts[0]), command: String(parts[1]),
                                               icon: icons.count > index ? icons[index] : nil))
                    } else {
                        cmds.append(nil)
                    }
                } else{
                    cmds.append(nil)
                }
            case 3:
                if let value = params["SwipeLeft"] {
                    let parts = value.split(separator: ";")
                    if parts.count >= 2 {
                        cmds.append(RemoteItem(id: "SwipeLeft", template: RemoteTemplate.Command, description: "Left", device: String(parts[0]), command: String(parts[1]),
                                               icon: icons.count > index ? icons[index] : nil))
                    } else {
                        cmds.append(nil)
                    }
                } else{
                    cmds.append(nil)
                }
            case 4:
                if let value = params["Tap"] {
                    let parts = value.split(separator: ";")
                    if parts.count >= 2 {
                        cmds.append(RemoteItem(id: "Tap", template: RemoteTemplate.Command, description: "Return", device: String(parts[0]), command: String(parts[1]),
                                               icon: icons.count > index ? icons[index] : nil))
                    } else {
                        cmds.append(nil)
                    }
                } else{
                    cmds.append(nil)
                }
            case 5:
                if let value = params["SwipeRight"] {
                    let parts = value.split(separator: ";")
                    if parts.count >= 2 {
                        cmds.append(RemoteItem(id: "SwipeRight", template: RemoteTemplate.Command, description: "Right", device: String(parts[0]), command: String(parts[1]),
                                               icon: icons.count > index ? icons[index] : nil))
                    } else {
                        cmds.append(nil)
                    }
                } else{
                    cmds.append(nil)
                }
            case 7:
                if let value = params["SwipeDown"] {
                    let parts = value.split(separator: ";")
                    if parts.count >= 2 {
                        cmds.append(RemoteItem(id: "SwipeDown", template: RemoteTemplate.Command, description: "Down", device: String(parts[0]), command: String(parts[1]),
                                               icon: icons.count > index ? icons[index] : nil))
                    } else {
                        cmds.append(nil)
                    }
                } else{
                    cmds.append(nil)
                }

            default:
                cmds.append(nil)
            }
        }
        return cmds
    }
    
    var body: some View {
        let rowHeight = calcRowHeight()
        let columnWidth = calcColumnWidth()
        let icons = buildIcons()
        let remoteItems = buildRemoteItems(icons: icons)
        let rowCount = 0...2
        let colCount = 0...2
        let rowCountArray = Array(rowCount)
        let colCountArray = Array(colCount)
        VStack {
            Picker("Mode", selection: $selectedMode) {
                Text("Button").tag(0)
                Text("Gesture").tag(1)
            }
            .pickerStyle(.segmented)
            Spacer()
            ZStack {
                if selectedMode == 1 {
                    Rectangle()
                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                }
                Grid (alignment: .topLeading) {
                    ForEach(rowCountArray, id: \.self) { y in
                        GridRow {
                            ForEach(colCountArray, id: \.self) { x in
                                if selectedMode == 0 {
                                    if remoteItems[3 * y + x] != nil {
                                        RemoteButton(remoteItem: remoteItems[3 * y + x]!, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                                            .frame(width: columnWidth - 10, height: rowHeight - 10)
                                            .padding(5)
                                    } else {
                                        if icons[3 * y + x] != nil {
                                            AsyncServerImage(imageWidth: Int(columnWidth) - 10, imageHeight: Int(rowHeight) - 10, imageId: icons[3 * y + x], background: false)
                                                .frame(width: columnWidth - 10, height: rowHeight - 10)
                                                .padding(5)
                                        } else {
                                            Rectangle()
                                                .frame(width: columnWidth, height: rowHeight)
                                                .foregroundColor(.clear)
                                        }
                                    }
                                } else {
                                    if icons[3 * y + x] != nil {
                                        AsyncServerImage(imageWidth: Int(columnWidth) - 10, imageHeight: Int(rowHeight) - 10, imageId: icons[3 * y + x], background: false)
                                            .frame(width: columnWidth - 10, height: rowHeight - 10)
                                            .padding(5)
                                    } else {
                                        Rectangle()
                                            .frame(width: columnWidth, height: rowHeight)
                                            .foregroundColor(.clear)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: selectedMode) {
            if selectedMode == 0 {
                disableScroll = false
            } else {
                disableScroll = true
            }
        }
        .onAppear() {
            selectedMode = 0
            disableScroll = false
        }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [IState] = []
    @Previewable @State var disableScroll: Bool = false
    var remoteItem: RemoteItem? = nil
    
    TouchView(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, disableScroll: $disableScroll)
}
