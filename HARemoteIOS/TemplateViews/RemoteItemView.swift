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
    var targetHeight: CGFloat = 220
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [HAState]
    @Binding var orientation: UIDeviceOrientation
    @Binding var disableScroll: Bool
    
    func calcInlineRowHeightWidth(columns: Int) -> CGFloat {
        if let half = remoteItem?.gridHalfHeight, half {
            return mainWindowSize.width / CGFloat(columns) / 2
        }
        return mainWindowSize.width / CGFloat(columns)
    }
    
    var body: some View {
            if remoteItem != nil {
                switch remoteItem?.template {
                case .Command:
                    RemoteButton(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .OnOff:
                    RemoteToggle(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .Headline:
                    Text(remoteItem?.description ?? "Unknown")
                        .padding()
                        .truncationMode(.middle)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.3)
                        .font(.title)
                        .frame(height: targetHeight)
                case .State:
                    RemoteState(remoteItem: remoteItem, targetHeight: targetHeight, remoteStates: $remoteStates)
                case .List:
                    ListView(remoteItem: remoteItem, level: level,
                             targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                case .Wrap:
                    Text("Remote Item Template is Wrap")
                case .Grid3X4:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 4, columns: 3, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                case .Grid3x4Inline:
                    let rows = remoteItem?.calculateUsedGridRows() ?? 0
                    HAGrid(remoteItem: remoteItem, level: level, rows: rows, columns: 3, inline: true, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                        .frame(height: calcInlineRowHeightWidth(columns: 3) * CGFloat(rows))
                case .Grid4X5:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 5, columns: 4, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                case .Grid4x5Inline:
                    let rows = remoteItem?.calculateUsedGridRows() ?? 0
                    HAGrid(remoteItem: remoteItem, level: level, rows: rows, columns: 4, inline: true, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                        .frame(height: calcInlineRowHeightWidth(columns: 4) * CGFloat(rows))
                case .Slider:
                    VolumeSlider(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .Combobox:
                    RemoteCombobox(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SliderHue:
                    BriSlider(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SliderHueSatBri:
                    HueSatBriSlider(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SliderTempBri:
                    TempBriSlider(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SliderHueHue:
                    HueSlider(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SliderHueBri:
                    BriSlider(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SliderHueTemp:
                    TempSlider(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SliderHueSat:
                    SatSlider(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .Space:
                    Text("Remote Item Template is Space")
                case .Divider:
                    VStack {
                        Divider()
                    }
                case .Touch:
                    TouchView(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, disableScroll: $disableScroll)
                        .frame(height: calcInlineRowHeightWidth(columns: 3) * 3 + 30)
                case .SelectionList:
                    HueOnOffMulti(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SelectionListTempBri:
                    TempBriMulti(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SelectionListHueSatBri:
                    HueSatBriMulti(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SelectionListBri:
                    BriMulti(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .CommandList:
                    RemoteButtonCommandList(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
                case .SelectionListParameter:
                    Text("Remote Item Template is SelectionListParameter")
                case .StateList:
                    Text("Remote Item Template is StateList")
                case .Grid5x3:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 3, columns: 5, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                case .Grid5x3Inline:
                    let rows = remoteItem?.calculateUsedGridRows() ?? 0
                    HAGrid(remoteItem: remoteItem, level: level, rows: rows, columns: 5, inline: true, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                        .frame(height: calcInlineRowHeightWidth(columns: 5) * CGFloat(rows))
                case .Grid6x4:
                    HAGrid(remoteItem: remoteItem, level: level, rows: 4, columns: 6, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                case .Grid6x4Inline:
                    let rows = remoteItem?.calculateUsedGridRows() ?? 0
                    HAGrid(remoteItem: remoteItem, level: level, rows: rows, columns: 6, inline: true, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                        .frame(height: calcInlineRowHeightWidth(columns: 6) * CGFloat(rows))
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
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [HAState] = []
    @Previewable @State var orientation: UIDeviceOrientation = UIDeviceOrientation.portrait
    @Previewable @State var disableScroll: Bool = false
    var remoteItem: RemoteItem? = nil
    
    RemoteItemView(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates, orientation: $orientation, disableScroll: $disableScroll)
}

