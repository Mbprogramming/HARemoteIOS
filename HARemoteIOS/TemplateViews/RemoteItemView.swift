//
//  RemoteItemView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 25.11.25.
//

import SwiftUI

struct RemoteItemView: View {
    private var remoteItemContent: RemoteItem?
    private var levelIntern: Int = 0
    @Environment(\.mainWindowSize) var mainWindowSize

    
    init(remoteItem: RemoteItem? = nil, level: Int = 0) {
        remoteItemContent = remoteItem
        levelIntern = level
    }
    
    var body: some View {
        GeometryReader { geo in
            if remoteItemContent != nil {
                switch remoteItemContent?.template {
                case .Command:
                    Text("Remote Item Template is Command")
                case .OnOff:
                    Text("Remote Item Template is OnOff")
                case .Headline:
                    Text("Remote Item Template is Headline")
                case .State:
                    Text("Remote Item Template is State")
                case .List:
                    ListView(remoteItem: remoteItemContent, level: levelIntern)
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
                    Text("Remote Item Template is Empty List")
                case nil:
                    Text("Remote Item Template is nil")
                }
            } else {
                Text("Remote Item is nil")
            }
        }
    }
}

#Preview {
    RemoteItemView()
}
