//
//  HueSatBriSlider.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 10.12.25.
//

import SwiftUI

struct SatMenu: View {
    @Binding var hueSatBriModel: HueSatBriTempModel
    var body: some View {
        HStack{
            Menu {
                Button("0%") {
                    hueSatBriModel.saturation = hueSatBriModel.saturationMin
                }
                Button("25%") {
                    let temp: Double = (Double(hueSatBriModel.saturationMax) - Double(hueSatBriModel.saturationMin)) * 0.25 + Double(hueSatBriModel.saturationMin)
                    hueSatBriModel.saturation = Int(temp)
                }
                Button("50%") {
                    let temp: Double = (Double(hueSatBriModel.saturationMax) - Double(hueSatBriModel.saturationMin)) * 0.5 + Double(hueSatBriModel.saturationMin)
                    hueSatBriModel.saturation = Int(temp)
                }
                Button("75%") {
                    let temp: Double = (Double(hueSatBriModel.saturationMax) - Double(hueSatBriModel.saturationMin)) * 0.75 + Double(hueSatBriModel.saturationMin)
                    hueSatBriModel.saturation = Int(temp)
                }
                Button("100%") {
                    hueSatBriModel.saturation = hueSatBriModel.saturationMax
                }
            } label: {
                HStack {
                    Text("\(hueSatBriModel.saturationString)")
                        .font(.caption)
                    Image(systemName: "chevron.down")
                }
            }
            .frame(width: 75)
        }
    }
}

struct HueMenu: View {
    @Binding var hueSatBriModel: HueSatBriTempModel
    var body: some View {
        HStack{
            Menu {
                Button(action: {
                    hueSatBriModel.hue = hueSatBriModel.hueMin
                }){
                    Label("0°", systemImage: "square.fill")
                }
                .tint(Color.red)
                Button(action: {
                    let temp: Double = (Double(hueSatBriModel.hueMax) - Double(hueSatBriModel.hueMin)) / 6 + Double(hueSatBriModel.hueMin)
                    hueSatBriModel.hue = Int(temp)
                }) {
                    Label("60°", systemImage: "square.fill")
                }
                .tint(Color.yellow)
                Button(action: {
                    let temp: Double = (Double(hueSatBriModel.hueMax) - Double(hueSatBriModel.hueMin)) / 6 * 2 + Double(hueSatBriModel.hueMin)
                    hueSatBriModel.hue = Int(temp)
                }){
                    Label("120°", systemImage: "square.fill")
                }
                .tint(Color.green)
                Button(action: {
                    let temp: Double = (Double(hueSatBriModel.hueMax) - Double(hueSatBriModel.hueMin)) * 0.5 + Double(hueSatBriModel.hueMin)
                    hueSatBriModel.hue = Int(temp)
                }){
                    Label("180°", systemImage: "square.fill")
                }
                .tint(Color.cyan)
                Button(action: {
                    let temp: Double = (Double(hueSatBriModel.hueMax) - Double(hueSatBriModel.hueMin)) / 6 * 4 + Double(hueSatBriModel.hueMin)
                    hueSatBriModel.hue = Int(temp)
                }){
                    Label("240°", systemImage: "square.fill")
                }
                .tint(Color.blue)
                Button(action: {
                    let temp: Double = (Double(hueSatBriModel.hueMax) - Double(hueSatBriModel.hueMin)) / 6 * 5 + Double(hueSatBriModel.hueMin)
                    hueSatBriModel.hue = Int(temp)
                }) {
                    Label("300°", systemImage: "square.fill")
                }
                .tint(Color(red: 1.0, green: 0.0, blue: 1.0))
            } label: {
                HStack {
                    Text("\(hueSatBriModel.hueString)")
                        .font(.caption)
                    Image(systemName: "chevron.down")
                }
            }
            .frame(width: 75)
        }
    }
}


struct HueSatBriSlider: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [IState]
    
    @State private var sliderVisible: Bool = false
    
    @State private var hueSatBriModel: HueSatBriTempModel = HueSatBriTempModel()
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        RemoteBaseButton(remoteItem: remoteItem, action: {
            hueSatBriModel.setRanges(min: remoteItem?.min ?? "", max: remoteItem?.max ?? "")
            if let state = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice }) {
                hueSatBriModel.setState(state: state)
            }
            
            sliderVisible.toggle()
        }, remoteStates: $remoteStates)
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
                    HueMenu(hueSatBriModel: $hueSatBriModel)
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
                    SatMenu(hueSatBriModel: $hueSatBriModel)
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
                    BriMenu(hueSatBriModel: $hueSatBriModel)
                        .frame(width: 75)
                    Slider(value: $hueSatBriModel.brightnessDouble, in: hueSatBriModel.brightnessRange)
                        .tint(.clear)
                        .background(brightnessGradient.cornerRadius(20).frame(height:20))
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
                        let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: hueSatBriModel.hueSatBriComplete)
                        mainModel.executeCommand(id: id)
                        sliderVisible.toggle()
                    }
                    .padding()
                }
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    HueSatBriSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}
