//
//  HueSatBriSlider.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 10.12.25.
//

import SwiftUI

struct HueSatBriSlider: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    @State private var sliderVisible: Bool = false
    
    @State private var hueSatBriModel: HueSatBriModel = HueSatBriModel()
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        Button(action: {
            hueSatBriModel.setRanges(min: remoteItem?.min ?? "", max: remoteItem?.max ?? "")
            if let state = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice }) {
                hueSatBriModel.setState(state: state)
            }
            
            sliderVisible.toggle()
        }){
            HStack {
                let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
                ButtonTextAndIcon(currentRemoteItem: remoteItem, currentState: currentState)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $sliderVisible) {
            let hueGradient = LinearGradient(gradient: Gradient(colors: (0...359).map {
                Color(hue: Double($0) / 360.0, saturation: 1.0, brightness: 1.0)
            }), startPoint: .leading, endPoint: .trailing)
            
            let saturationGradient = LinearGradient(gradient: Gradient(colors: (0...255).map {
                Color(hue: hueSatBriModel.hueDouble, saturation: Double($0) / 255.0, brightness: 1.0)
            }), startPoint: .leading, endPoint: .trailing)

            let brightnessGradient = LinearGradient(gradient: Gradient(colors: (0...255).map {
                Color(hue: hueSatBriModel.hueDouble, saturation: 1.0, brightness: Double($0) / 255.0)
            }), startPoint: .leading, endPoint: .trailing)

            VStack {
                Text("Hue")
                    .font(.caption)
                HStack{
                    Text("\(hueSatBriModel.hueString)")
                        .frame(width: 75)
                    Slider(value: $hueSatBriModel.hueDouble, in: hueSatBriModel.hueRange)
                        .tint(.clear)
                        .background(hueGradient.cornerRadius(20).frame(height:20))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                Spacer()
                Text("Saturation")
                    .font(.caption)
                HStack{
                    Text("\(hueSatBriModel.saturationString)")
                        .frame(width: 75)
                    Slider(value: $hueSatBriModel.saturationDouble, in: hueSatBriModel.saturationRange)
                        .tint(.clear)
                        .background(saturationGradient.cornerRadius(20).frame(height:20))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                Spacer()
                Text("Brightness")
                    .font(.caption)
                HStack{
                    Text("\(hueSatBriModel.brightnessString)")
                        .frame(width: 75)
                    Slider(value: $hueSatBriModel.brightnessDouble, in: hueSatBriModel.brightnessRange)
                        .tint(.clear)
                        .background(brightnessGradient.cornerRadius(20).frame(height:20))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding()
            .presentationDetents([.medium])
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
    
    HueSatBriSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
