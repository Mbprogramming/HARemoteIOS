//
//  ButtonTextAndIcon.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 01.12.25.
//

import SwiftUI

struct ButtonTextAndIcon: View {
    var currentRemoteItem: RemoteItem?
    var currentState: HAState?
    var targetHeight: CGFloat = 150
    
    @Binding var parentHeight: CGFloat
    
    func getIcon() -> String? {
        guard let currentRemoteItem else { return nil }
        guard let icon = currentRemoteItem.icon else { return nil }
        return icon
    }
    
    var body: some View {
        if currentState != nil {
            VStack {
                if currentState?.showImage == true {
                    if let icon = currentState?.icon {
                        AsyncServerImage(imageWidth: targetHeight >= 50.0 ? 40 : 20, imageHeight: targetHeight >= 50.0 ? 40 : 20, imageId: icon)
                            .frame(width: targetHeight >= 50.0 ? 40 : 20, height: targetHeight >= 50.0 ? 40 : 20)
                    }
                }                
                if currentState?.showText == true {
                    Text(currentState?.completeValue ?? "")
                        .truncationMode(.middle)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .font(.title)
                }
                if targetHeight >= 50.0 {
                    Spacer()
                    HStack {
                        Text(currentRemoteItem?.description ?? "Unknown")
                            .font(.footnote)
                            .lineLimit(1)
                            .truncationMode(.head)
                        Spacer()
                    }
                }
            }
            .frame(height: targetHeight)
            .background(GeometryReader { geo in
                Color.clear.onAppear {
                    parentHeight = geo.size.height
                }
            })
        } else {
            if currentRemoteItem?.icon != nil {
                VStack{
                    AsyncServerImage(imageWidth: targetHeight >= 50.0 ? 40 : 20, imageHeight: targetHeight >= 50.0 ? 40 : 20, imageId: getIcon())
                        .frame(width: targetHeight >= 50.0 ? 40 : 20, height: targetHeight >= 50.0 ? 40 : 20 )
                    if targetHeight >= 50.0 {
                        Text(currentRemoteItem?.description ?? "Unknown")
                            .truncationMode(.middle)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.3)
                    }
                }
                .frame(height: targetHeight)
                .background(GeometryReader { geo in
                    Color.clear.onAppear {
                        parentHeight = geo.size.height
                    }
                })
            } else {
                Text(currentRemoteItem?.description ?? "Unknown")
                    .truncationMode(.middle)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.3)
                    .font(.title)
                    .frame(height: targetHeight)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear {
                            parentHeight = geo.size.height
                        }
                    })
            }
        }
    }
    
}

#Preview {
    @Previewable @State var parentHeight: CGFloat = 60
    var remoteItem: RemoteItem? = nil
    var targetHeight: CGFloat = 60

    ButtonTextAndIcon(currentRemoteItem: remoteItem, targetHeight: targetHeight, parentHeight: $parentHeight)
}
