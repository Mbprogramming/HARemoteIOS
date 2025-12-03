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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    func getBackgroundUrl() -> String {
        guard let currentRemoteItem else { return "" }
        guard let icon = currentRemoteItem.icon else { return "" }
        if colorScheme == .light {
            return "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=" + icon
        } else {
            return "http://192.168.5.106:5000/api/homeautomation/Bitmap?inverted=true&width=40&height=40&id=" + icon
        }
    }
    
    var body: some View {
        if currentState != nil {
            VStack {
                if currentState?.showImage == true {
                    if colorScheme == .light {
                        let iconUrl = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=\(currentState!.icon!)"
                        AsyncImage(url: URL(string: iconUrl))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    } else {
                        let iconUrl = "http://192.168.5.106:5000/api/homeautomation/Bitmap?inverted=true&width=40&height=40&id=\(currentState!.icon!)"
                        AsyncImage(url: URL(string: iconUrl))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
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
                    AsyncImage(url: URL(string: getBackgroundUrl()))
                        .aspectRatio(contentMode: .fit)
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
