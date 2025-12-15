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
                    RemoteButton(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .OnOff:
                    RemoteToggle(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Headline:
                    Text(remoteItem?.description ?? "Unknown")
                        .padding()
                        .truncationMode(.middle)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.3)
                        .font(.title)
                case .State:
                    RemoteState(remoteItem: remoteItem, remoteStates: $remoteStates)
                case .List:
                    ListView(remoteItem: remoteItem, level: level,
                             height: height, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Wrap:
                    Text("Remote Item Template is Wrap")
                case .Grid3X4:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 4, columns: 3, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Grid3x4Inline:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 4, columns: 3, inline: true, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                        .frame(height: calcInlineRowHeightWidth(columns: 3) * 4)
                case .Grid4X5:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 5, columns: 4, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Grid4x5Inline:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 5, columns: 4, inline: true, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                        .frame(height: calcInlineRowHeightWidth(columns: 4) * 5)
                case .Slider:
                    Text("Remote Item Template is Slider")
                case .Combobox:
                    Text("Remote Item Template is Combobox")
                case .SliderHue:
                    Text("Remote Item Template is SliderHue")
                case .SliderHueSatBri:
                    HueSatBriSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .SliderTempBri:
                    TempBriSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .SliderHueHue:
                    HueSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .SliderHueBri:
                    BriSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .SliderHueTemp:
                    TempSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .SliderHueSat:
                    SatSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Space:
                    Text("Remote Item Template is Space")
                case .Divider:
                    VStack {
                        Divider()
                    }
                case .Touch:
                    Text("Remote Item Template is Touch")
                case .SelectionList:
                    HueOnOffMulti(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .SelectionListTempBri:
                    Text("Remote Item Template is SelectionListTempBri")
                case .SelectionListHueSatBri:
                    Text("Remote Item Template is SelectionLostHueSatBri")
                case .SelectionListBri:
                    Text("Remote Item Template is SelectionListBri")
                case .CommandList:
                    RemoteButtonCommandList(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .SelectionListParameter:
                    Text("Remote Item Template is SelectionListParameter")
                case .StateList:
                    Text("Remote Item Template is StateList")
                case .Grid5x3:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 3, columns: 5, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Grid5x3Inline:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 3, columns: 5, inline: true, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                        .frame(height: calcInlineRowHeightWidth(columns: 5) * 5)
                case .Grid6x4:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 4, columns: 6, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                case .Grid6x4Inline:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 4, columns: 6, inline: true, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                        .frame(height: calcInlineRowHeightWidth(columns: 6) * 5)
                case .TwoColumnList:
                    Text("Remote Item Template is TwoColumnList")
                case .EmptyListItem:
                    let height = mainWindowSize.height * 0.5
                    Spacer(minLength: height)
                case nil:
                    Text("Remote Item Template is nil")
                }
            } else {
                ProgressView()
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

