//
//  TempBriSlider.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 11.12.25.
//

import SwiftUI

struct TempBriSlider: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    @State private var sliderVisible: Bool = false
    
    @State private var hueSatBriModel: HueSatBriTempModel = HueSatBriTempModel()
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    private func colorTemperatureToRGB(_ kelvin: Double) -> Color {
        let temp = kelvin / 100.0
        var red, green, blue: Double

        // Rot
        if temp <= 66 {
            red = 255
        } else {
            red = 329.698727446 * pow(temp - 60, -0.1332047592)
            red = max(0, min(255, red))
        }

        // Grün
        if temp <= 66 {
            green = 99.4708025861 * log(temp) - 161.1195681661
        } else {
            green = 288.1221695283 * pow(temp - 60, -0.0755148492)
        }
        green = max(0, min(255, green))

        // Blau
        if temp >= 66 {
            blue = 255
        } else if temp <= 19 {
            blue = 0
        } else {
            blue = 138.5177312231 * log(temp - 10) - 305.0447927307
            blue = max(0, min(255, blue))
        }

        return Color(
            red: red / 255.0,
            green: green / 255.0,
            blue: blue / 255.0
        )
    }
    
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
            let temperatures = stride(from: 6535, through: 2000, by: -50)
            let gradientColors = temperatures.map { colorTemperatureToRGB(Double($0)) }

            let temperatureGradient = LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .leading,
                endPoint: .trailing
            )
            //let colorFrom = colorTemperatureToRGB(hueSatBriModel.temperatureDouble)
            //let colorTo = colorTemperatureToRGB(hueSatBriModel.temperatureDouble)
            let brightnessGradient = LinearGradient(gradient: Gradient(colors: (0...255).map {
                Color(hue: hueSatBriModel.hueDouble, saturation: 1.0, brightness: Double($0) / 255.0)
            }), startPoint: .leading, endPoint: .trailing)

            VStack {
                Text("Temperature")
                    .font(.caption)
                HStack{
                    Text("\(hueSatBriModel.temperatureString)")
                        .frame(width: 75)
                    Slider(value: $hueSatBriModel.temperatureDouble, in: hueSatBriModel.temperatureRange)
                        .tint(.clear)
                        .background(temperatureGradient.cornerRadius(20).frame(height:20))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
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
                Spacer()
                HStack {
                    Spacer()
                    Button("Ok"){
                        let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: hueSatBriModel.tempBriComplete)
                        commandIds.append(id)
                        sliderVisible.toggle()
                    }
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
    
    TempBriSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
