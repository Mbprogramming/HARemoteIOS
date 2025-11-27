//
//  RemoteItemView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 25.11.25.
//

import SwiftUI

struct RemoteItemView: View {
    var remoteItem: RemoteItem?
    var level: Int = 0
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    
    var body: some View {
            if remoteItem != nil {
                switch remoteItem?.template {
                case .Command:
                    Text("Remote Item Template is Command")
                case .OnOff:
                    Text("Remote Item Template is OnOff")
                case .Headline:
                    Text(remoteItem?.description ?? "Unknown")
                        .padding()
                        .font(.title)
                case .State:
                    Text("Remote Item Template is State")
                case .List:
                    ListView(remoteItem: remoteItem, level: level,
                             currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack)
                        .padding()
                case .Wrap:
                    Text("Remote Item Template is Wrap")
                case .Grid3X4:
                    Text("Remote Item Template is Grid3X4")
                case .Grid3x4Inline:
                    Text("Remote Item Template is Grid3x4Inline")
                case .Grid4X5:
                    Text("Remote Item Template is Grid4X5")
                case .Grid4x5Inline:
                    Text("Remote Item Template is Grid4x5Inline")
                case .Slider:
                    Text("Remote Item Template is Slider")
                case .Combobox:
                    Text("Remote Item Template is Combobox")
                case .SliderHue:
                    Text("Remote Item Template is SliderHue")
                case .SliderHueSatBri:
                    Text("Remote Item Template is SliderHueSatBri")
                case .SliderTempBri:
                    Text("Remote Item Template is SliderTempBri")
                case .SliderHueHue:
                    Text("Remote Item Template is SliderHueHue")
                case .SliderHueBri:
                    Text("Remote Item Template is SliderHueBri")
                case .SliderHueTemp:
                    Text("Remote Item Template is SliderHueTemp")
                case .SliderHueSat:
                    Text("Remote Item Template is SliderHueSat")
                case .Space:
                    Text("Remote Item Template is Space")
                case .Divider:
                    Text("Remote Item Template is Divider")
                case .Touch:
                    Text("Remote Item Template is Touch")
                case .SelectionList:
                    Text("Remote Item Template is SelectionList")
                case .SelectionListTempBri:
                    Text("Remote Item Template is SelectionListTempBri")
                case .SelectionListHueSatBri:
                    Text("Remote Item Template is SelectionLostHueSatBri")
                case .SelectionListBri:
                    Text("Remote Item Template is SelectionListBri")
                case .CommandList:
                    Text("Remote Item Template is CommandList")
                case .SelectionListParameter:
                    Text("Remote Item Template is SelectionListParameter")
                case .StateList:
                    Text("Remote Item Template is StateList")
                case .Grid5x3:
                    Text("Remote Item Template is Grid5x3")
                case .Grid5x3Inline:
                    Text("Remote Item Template is Grid5x3Inline")
                case .Grid6x4:
                    Text("Remote Item Template is Grid6x4")
                case .Grid6x4Inline:
                    Text("Remote Item Template is Grid6x4Inline")
                case .TwoColumnList:
                    Text("Remote Item Template is TwoColumnList")
                case .EmptyListItem:
                    let height = mainWindowSize.height * 0.5
                    Spacer(minLength: height)
                case nil:
                    Text("Remote Item Template is nil")
                }
            } else {
                Text("Remote Item is nil")
            }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    var remoteItem: RemoteItem? = nil
    
    RemoteItemView(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack)
}
