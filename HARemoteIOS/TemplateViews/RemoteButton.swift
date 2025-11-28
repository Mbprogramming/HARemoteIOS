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
                print("Click " + (remoteItem?.device ?? "")  + " : " + (remoteItem?.command ?? ""))
            }
            }){
            HStack {
                Text(remoteItem?.description ?? "Unknown")
                    .padding()
                    .truncationMode(.middle)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.3)
                    .font(.title)
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
            .padding()
            .frame(maxWidth: .infinity, maxHeight: height)
        }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 10))
        //.buttonStyle(.glass)
        //.frame(height: 150)
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    var remoteItem: RemoteItem? = nil
    
    RemoteButton(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack)
}

