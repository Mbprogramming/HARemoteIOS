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
    
    func getBackground() -> String? {
        guard let remoteItem else { return nil }
        guard let backgroundImage = remoteItem.backgroundImage else { return nil }
        return backgroundImage
    }
    
    var body: some View {
        GeometryReader { geo in
            if remoteItem?.backgroundImage != nil {
                ZStack {
                    AsyncServerImage(imageWidth: 400, imageHeight: 400, imageId: getBackground(), background: true)
                        .frame(width: geo.size.width - 20, height: geo.size.height - 20)
                        .padding()
                    if colorScheme == .light {
                        Rectangle()
                            .fill(Color.white.opacity(0.75))
                    } else {
                        Rectangle()
                            .fill(Color.black.opacity(0.75))
                    }
                }
                
            }
        }
    }
}

#Preview {
    var remoteItem: RemoteItem? = nil
    BackgroundImage(remoteItem: remoteItem)
}
