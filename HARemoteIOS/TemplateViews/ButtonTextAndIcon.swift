//
//  ButtonTextAndIcon.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 01.12.25.
//

import SwiftUI

struct ButtonTextAndIcon: View {
    var currentRemoteItem: RemoteItem?
    var currentState: IState?
    
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
                    AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: currentState!.icon!)
                        .frame(width: parentHeight >= 50.0 ? 40 : 20, height: parentHeight >= 50.0 ? 40 : 20 )
                }
                if currentState?.showText == true && parentHeight >= 50.0 {
                    Text(currentState?.completeValue ?? "")
                        .truncationMode(.middle)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .font(.title)
                }
                Spacer()
                HStack {
                    Text(currentRemoteItem?.description ?? "Unknown")
                        .font(.footnote)
                        .lineLimit(1)
                        .truncationMode(.head)
                    Spacer()
                }
            }
        } else {
            if currentRemoteItem?.icon != nil {
                VStack{
                    AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: getIcon())
                        .frame(width: parentHeight >= 50.0 ? 40 : 20, height: parentHeight >= 50.0 ? 40 : 20 )
                    if parentHeight >= 50.0 {
                        Text(currentRemoteItem?.description ?? "Unknown")
                            .truncationMode(.middle)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.3)
                            .font(Font.custom("San Francisco", fixedSize: 8))
                    }
                }
            } else {
                Text(currentRemoteItem?.description ?? "Unknown")
                    .truncationMode(.middle)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.3)
                    .font(.title)
            }
        }
    }
    
}

#Preview {
    @Previewable @State var parentHeight: CGFloat = 60
    var remoteItem: RemoteItem? = nil

    ButtonTextAndIcon(currentRemoteItem: remoteItem, parentHeight: $parentHeight)
}
