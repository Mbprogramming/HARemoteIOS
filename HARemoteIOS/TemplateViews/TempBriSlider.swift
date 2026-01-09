//
//  TempBriSlider.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 11.12.25.
//

import SwiftUI

struct TempMenu: View {
    @Binding var hueSatBriModel: HueSatBriTempModel
    var body: some View {
        HStack{
            Menu {
                Button("2000K") {
                    hueSatBriModel.temperature = 500
                }
                Button("2700K") {
                    hueSatBriModel.temperature = 370
                }
                Button("3000K") {
                    hueSatBriModel.temperature = 333
                }
                Button("4500K") {
                    hueSatBriModel.temperature = 222
                }
            } label: {
                HStack {
                    Text("\(hueSatBriModel.temperatureString)")
                        .font(.caption)
                    Image(systemName: "chevron.down")
                }
            }
            .frame(width: 75)
        }
    }
}

struct BriMenu: View {
    @Binding var hueSatBriModel: HueSatBriTempModel
    var body: some View {
        HStack{
            Menu {
                Button("10%") {
                    let temp: Double = (Double(hueSatBriModel.brightnessMax) - Double(hueSatBriModel.brightnessMin)) * 0.1 + Double(hueSatBriModel.brightnessMin)
                    hueSatBriModel.brightness = Int(temp)
                }
                Button("25%") {
                    let temp: Double = (Double(hueSatBriModel.brightnessMax) - Double(hueSatBriModel.brightnessMin)) * 0.25 + Double(hueSatBriModel.brightnessMin)
                    hueSatBriModel.brightness = Int(temp)
                }
                Button("50%") {
                    let temp: Double = (Double(hueSatBriModel.brightnessMax) - Double(hueSatBriModel.brightnessMin)) * 0.5 + Double(hueSatBriModel.brightnessMin)
                    hueSatBriModel.brightness = Int(temp)
                }
                Button("75%") {
                    let temp: Double = (Double(hueSatBriModel.brightnessMax) - Double(hueSatBriModel.brightnessMin)) * 0.75 + Double(hueSatBriModel.brightnessMin)
                    hueSatBriModel.brightness = Int(temp)
                }
                Button("100%") {
                    hueSatBriModel.brightness = hueSatBriModel.brightnessMax
                }
            } label: {
                HStack {
                    Text("\(hueSatBriModel.brightnessString)")
                        .font(.caption)
                    Image(systemName: "chevron.down")
                }
            }
            .frame(width: 75)
        }
    }
}

struct TempBriSlider: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
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
        RemoteBaseButton(remoteItem: remoteItem, action: {
            hueSatBriModel.setRanges(min: remoteItem?.min ?? "", max: remoteItem?.max ?? "")
            if let state = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice }) {
                hueSatBriModel.setState(state: state)
            }
            
            sliderVisible.toggle()
        }, remoteStates: $remoteStates)
        .sheet(isPresented: $sliderVisible) {
            let temperatures = stride(from: 6535, through: 2000, by: -50)
            let gradientColors = temperatures.map { colorTemperatureToRGB(Double($0)) }

            let temperatureGradient = LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            let brightnessGradient = LinearGradient(
                        gradient: Gradient(stops: [
                            // Startpunkt (0% Helligkeit = Schwarz, da brightness 0.0 ist)
                            Gradient.Stop(color: Color(hue: 0.0, saturation: 0.0, brightness: 0.0), location: 0.0),
                            // Endpunkt (100% Helligkeit der Basisfarbe)
                            Gradient.Stop(color: colorTemperatureToRGB((1000000 / Double(hueSatBriModel.temperature))), location: 1.0)
                        ]),
                        startPoint: .leading, // Beginnt links
                        endPoint: .trailing   // Endet rechts
                    )
            
            VStack {
                Text("Temperature")
                    .font(.caption)
                HStack{
                    TempMenu(hueSatBriModel: $hueSatBriModel)
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
                    BriMenu(hueSatBriModel: $hueSatBriModel)
                        .frame(width: 75)
                    Slider(value: $hueSatBriModel.brightnessDouble, in: hueSatBriModel.brightnessRange)
                        .tint(.clear)
                        .background(brightnessGradient.cornerRadius(20).frame(height:20))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                Spacer()
                HStack {
                    Button("Cancel", systemImage: "xmark.circle") {
                        sliderVisible.toggle()
                    }
                    .padding()
                    Spacer()
                    Button("OK", systemImage: "checkmark.circle") {
                        let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: hueSatBriModel.tempBriComplete)
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
    
    TempBriSlider(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}
