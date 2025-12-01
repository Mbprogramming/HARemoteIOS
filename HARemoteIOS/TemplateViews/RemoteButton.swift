//
//  RemoteButton.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 25.11.25.
//

import SwiftUI

struct RemoteButton: View {
    var remoteItem: RemoteItem?
    var height: CGFloat = 150
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    
    var body: some View {
        Button(action: {
            if remoteItem?.template == RemoteTemplate.List
                || remoteItem?.template == RemoteTemplate.Wrap
                || remoteItem?.template == RemoteTemplate.Grid3X4
                || remoteItem?.template == RemoteTemplate.Grid4X5
                || remoteItem?.template == RemoteTemplate.Grid5x3 {
                guard let children = remoteItem?.children else { return }
                if children.count > 0 {
                    // Do not shadow the binding; unwrap into a different name
                    guard let current = currentRemoteItem else { return }
                    remoteItemStack.append(current)
                    guard let next = remoteItem else { return }
                    currentRemoteItem = next
                }
            }
            if remoteItem?.template == RemoteTemplate.Command {
                let id = HomeRemoteAPI.shared.sendCommand(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "")
                commandIds.append(id)
            }
            }){
            HStack {
                ButtonTextAndIcon(currentRemoteItem: remoteItem)
                if remoteItem?.template == RemoteTemplate.List
                    || remoteItem?.template == RemoteTemplate.Wrap
                    || remoteItem?.template == RemoteTemplate.Grid3X4
                    || remoteItem?.template == RemoteTemplate.Grid4X5
                    || remoteItem?.template == RemoteTemplate.Grid5x3 {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.footnote)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: height)
        }
        .buttonStyle(.bordered)
        .tint(Color.primary)
        .buttonBorderShape(.roundedRectangle(radius: 10))
        //.buttonStyle(.glass)
        //.frame(height: 150)
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var commandIds: [String] = []
    var remoteItem: RemoteItem? = nil
    
    RemoteButton(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds)
}

