//
//  AsyncServerImage.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 03.12.25.
//

import SwiftUI

struct AsyncServerImage: View {
    @Environment(\.colorScheme) private var colorScheme

    var imageWidth: Int = 40
    var imageHeight: Int = 40
    var imageId: String?
        
    func getBackgroundUrl(currentScheme: ColorScheme) -> String? {
        guard let icon = imageId else { return nil }
        if currentScheme == .light {
            return "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=\(imageWidth)&height=\(imageHeight)&id=" + icon
        } else {
            return "http://192.168.5.106:5000/api/homeautomation/Bitmap?inverted=true&width=\(imageWidth)&height=\(imageHeight)&id=" + icon
        }
    }
    
    var body: some View {
        let iconUrl = getBackgroundUrl(currentScheme: colorScheme)

        Group {
            if let iconUrl, let url = URL(string: iconUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        EmptyView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    AsyncServerImage()
}
