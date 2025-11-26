//
//  RemoteButton.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 25.11.25.
//

import SwiftUI

struct CustomGlassButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 5
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.thinMaterial)
            )
            .scaleEffect((configuration.isPressed ? 0.95 : 1.0))
    }
}

struct RemoteButton: View {
    private var remoteItemContent: RemoteItem?
    
    init(remoteItem: RemoteItem? = nil) {
        remoteItemContent = remoteItem
    }
    
    var body: some View {
        Button(action: {
            print("Click")
        }){
            HStack {
                Text(remoteItemContent?.description ?? "Unknown")
                    .padding()
                    .font(.title)
                if remoteItemContent?.template == RemoteTemplate.List
                    || remoteItemContent?.template == RemoteTemplate.Wrap
                    || remoteItemContent?.template == RemoteTemplate.Grid3X4
                    || remoteItemContent?.template == RemoteTemplate.Grid4X5
                    || remoteItemContent?.template == RemoteTemplate.Grid5x3 {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.footnote)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 150)
        }
        .buttonStyle(.glass)
    }
}

#Preview {
    RemoteButton()
}
