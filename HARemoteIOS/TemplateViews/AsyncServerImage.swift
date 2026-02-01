//
//  AsyncServerImage.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 03.12.25.
//

import SwiftUI
import Kingfisher

struct AsyncServerImage: View {
    @Environment(\.colorScheme) private var colorScheme

    var imageWidth: Int = 40
    var imageHeight: Int = 40
    var imageId: String?
    var background: Bool = false
        
    func getBackgroundUrl(currentScheme: ColorScheme) -> String? {
        guard let icon = imageId else { return nil }
        let baseCandidate = !HomeRemoteAPI.shared.server.isEmpty ? HomeRemoteAPI.shared.server : (HomeRemoteAPI.defaultServer ?? "")
        let base = baseCandidate.isEmpty ? nil : baseCandidate
        guard let baseUrl = base else { return nil }
        if currentScheme == .light {
            return "\(baseUrl)/api/homeautomation/Bitmap?width=\(imageWidth)&height=\(imageHeight)&id=\(icon)"
        } else {
            return "\(baseUrl)/api/homeautomation/Bitmap?inverted=true&width=\(imageWidth)&height=\(imageHeight)&id=\(icon)"
        }
    }
    
    var body: some View {
        let iconUrl = getBackgroundUrl(currentScheme: colorScheme)
        let cache = HomeRemoteAPI.shared.shouldIconCached(id: imageId ?? "")
        if let iconUrl, let url = URL(string: iconUrl) {
            if cache {
                KFImage(url)
                    .scaledToFit()
            } else {
                KFImage(url)
                    .forceRefresh()
                    .scaledToFit()
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    AsyncServerImage()
}
