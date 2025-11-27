//
//  BackgroundImage.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 27.11.25.
//

import SwiftUI

struct BackgroundImage: View {
    var remoteItem: RemoteItem?
    
    func getBackgroundUrl() -> String {
        guard let remoteItem else { return "" }
        guard let backgroundImage = remoteItem.backgroundImage else { return "" }
        return "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=400&height=400&id=" + backgroundImage
    }
    
    var body: some View {
        if remoteItem?.backgroundImage != nil {
            AsyncImage(url: URL(string: getBackgroundUrl())){ phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                case .failure:
                    Image(systemName: "wifi.slash")
                @unknown default:
                    EmptyView()
                }
            }
            .aspectRatio(contentMode: .fit)
        }
    }
}

#Preview {
    var remoteItem: RemoteItem? = nil
    BackgroundImage(remoteItem: remoteItem)
}
