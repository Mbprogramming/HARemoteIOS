//
//  HueSlider.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 12.12.25.
//

import SwiftUI

struct HueSlider: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    @State private var sliderVisible: Bool = false
    
    @State private var hueSatBriModel: HueSatBriTempModel = HueSatBriTempModel()
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        RemoteBaseButton(remoteItem: remoteItem, action: {
            hueSatBriModel.setRangesHue(min: remoteItem?.min ?? "", max: remoteItem?.max ?? "")
            if let state = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice }) {
                hueSatBriModel.setStateHue(state: state)
            }
            
            sliderVisible.toggle()
        }, remoteStates: $remoteStates)
        .popover(isPresented: $sliderVisible,
                 attachmentAnchor: .point(.center), // Ankerpunkt des Popovers relativ zum Button
                 arrowEdge: .top) {
            let hueGradient = LinearGradient(gradient: Gradient(colors: (0...359).map {
                Color(hue: Double($0) / 360.0, saturation: 1.0, brightness: 1.0)
            }), startPoint: .leading, endPoint: .trailing)
            
            VStack {
                Text("Hue")
                    .font(.caption)
                HStack{
                    HueMenu(hueSatBriModel: $hueSatBriModel)
                        .frame(width: 75)
                    Slider(value: $hueSatBriModel.hueDouble, in: hueSatBriModel.hueRange)
                        .tint(.clear)
                        .background(hueGradient.cornerRadius(20).frame(height:20))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                HStack {
                    Button("Cancel", systemImage: "xmark.circle") {
                        sliderVisible.toggle()
                    }
                    .padding()
                    Spacer()
                    Button("OK", systemImage: "checkmark.circle") {
                        let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: hueSatBriModel.hueComplete)
                        commandIds.append(id)
                        sliderVisible.toggle()
                    }
                    .padding()
                }
            }
            .padding()
            .frame(minWidth: mainWindowSize.width - 20)
            .presentationCompactAdaptation(.popover)
        }
        .buttonStyle(.bordered)
        .tint(Color.primary)
        .buttonBorderShape(.roundedRectangle(radius: 10))
        .shadow(radius: 5)
        //.buttonStyle(.glass)
        //.frame(height: 150)
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var commandIds: [String] = []
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    HueSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
