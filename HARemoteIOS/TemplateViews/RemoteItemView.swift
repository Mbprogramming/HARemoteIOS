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
    var height: CGFloat = 150
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    func calcInlineRowHeightWidth(columns: Int) -> CGFloat {
        return mainWindowSize.width / CGFloat(columns)
    }
    
    var body: some View {
            if remoteItem != nil {
                switch remoteItem?.template {
                case .Command:
                    RemoteButton(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds)
                        .frame(height: height)
                case .OnOff:
                    Text("Remote Item Template is OnOff")
                case .Headline:
                    Text(remoteItem?.description ?? "Unknown")
                        .frame(height: height)
                        .truncationMode(.middle)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.3)
                        .font(.title)
                case .State:
                    RemoteState(remoteItem: remoteItem, remoteStates: $remoteStates)
                        .frame(height: height)
                case .List:
                    ListView(remoteItem: remoteItem, level: level,
                             height: height, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Wrap:
                    Text("Remote Item Template is Wrap")
                case .Grid3X4:
                    HAGrid(remoteItem: remoteItem, level: level, height: height, rows: 4, columns: 3, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Grid3x4Inline:
                    HAGrid(remoteItem: remoteItem, level: level, height: height, rows: 4, columns: 3, inline: true, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                        .frame(height: calcInlineRowHeightWidth(columns: 3) * 4)
                case .Grid4X5:
                    HAGrid(remoteItem: remoteItem, level: level, height: height, rows: 5, columns: 4, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Grid4x5Inline:
                    HAGrid(remoteItem: remoteItem, level: level, height: height, rows: 5, columns: 4, inline: true, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                        .frame(height: calcInlineRowHeightWidth(columns: 4) * 5)
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
                    VStack {
                        Spacer(minLength: 3)
                        Rectangle()
                            .fill(.clear)
                            .border(Color.black)
                            .frame(height: 1)
                        Spacer(minLength: 3)
                    }
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
                    HAGrid(remoteItem: remoteItem, level: level, height: height, rows: 3, columns: 5, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Grid5x3Inline:
                    Text("Remote Item Template is Grid5x3Inline")
                case .Grid6x4:
                    HAGrid(remoteItem: remoteItem, level: level, height: height, rows: 4, columns: 6, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
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
    @Previewable @State var commandIds: [String] = []
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    RemoteItemView(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}

