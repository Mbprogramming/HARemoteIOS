//
//  BackgroundImage.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 27.11.25.
//

import SwiftUI

struct BackgroundImage: View {
    var remoteItem: RemoteItem?
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    func getBackgroundUrl() -> String {
        guard let remoteItem else { return "" }
        guard let backgroundImage = remoteItem.backgroundImage else { return "" }
        if colorScheme == .light {
            return "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=400&height=400&id=" + backgroundImage
        } else {
            return "http://192.168.5.106:5000/api/homeautomation/Bitmap?inverted=true&width=400&height=400&id=" + backgroundImage
        }
    }
    
    var body: some View {
        if remoteItem?.backgroundImage != nil {
            ZStack {
                AsyncImage(url: URL(string: getBackgroundUrl()))
                //            { phase in
                //                switch phase {
                //                case .empty:
                //                    ProgressView()
                //                case .success(let image):
                //                    image
                //                        .resizable()
                //                case .failure:
                //                    Image(systemName: "wifi.slash")
                //                @unknown default:
                //                    EmptyView()
                //                }
                //            }
                    .aspectRatio(contentMode: .fit)
                if colorScheme == .light {
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                } else {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                }
            }
        }
    }
}

#Preview {
    var remoteItem: RemoteItem? = nil
    BackgroundImage(remoteItem: remoteItem)
}
