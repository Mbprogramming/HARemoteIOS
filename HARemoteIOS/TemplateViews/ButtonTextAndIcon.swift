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
                        .frame(width: 40, height: 40)
                }
                if currentState?.showText == true {
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
                        .frame(width: 40, height: 40)
                    Text(currentRemoteItem?.description ?? "Unknown")
                        .truncationMode(.middle)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.3)
                        .font(Font.custom("San Francisco", fixedSize: 8))
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
    var remoteItem: RemoteItem? = nil
    ButtonTextAndIcon(currentRemoteItem: remoteItem)
}
