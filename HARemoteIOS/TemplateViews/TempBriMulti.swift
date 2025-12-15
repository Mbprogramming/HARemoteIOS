//
//  TempBriMulti.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.12.25.
//

import SwiftUI

struct TempBriMulti: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    @State private var sliderVisible: Bool = false
    @State private var listVisible: Bool = false
    
    @State private var hueSatBriModel: HueSatBriTempModel = HueSatBriTempModel()
    @State var selection = Set<StringStringTuple>()
    @State private var editMode: EditMode = .active
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    private let commandParameter = CommandParameterForMultipleValues()
    
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
            
            listVisible.toggle()
        }){
            HStack {
                let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
                ButtonTextAndIcon(currentRemoteItem: remoteItem, currentState: currentState)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $listVisible) {
            
            if let items = remoteItem?.steps {
                List(items, id: \.self, selection: $selection) {
                    Text($0.item2 ?? "")
                }
                .environment(\.editMode, $editMode)
                Spacer()
                HStack {
                    Button("Cancel", systemImage: "xmark.circle") {
                        listVisible.toggle()
                    }
                    .padding()
                    Spacer()
                    Button("Continue", systemImage: "arrow.right.circle") {
                        // Collect selected ids and descriptions
                        selection.forEach { tuple in
                            if let id = tuple.item1 {
                                commandParameter.Ids.append(id)
                            }
                            if let desc = tuple.item2 {
                                commandParameter.Descriptions.append(desc)
                            }
                        }
                        listVisible.toggle()
                        sliderVisible.toggle()
                    }
                    
                    .padding()
                }
                .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $sliderVisible) {
            let title = commandParameter.Descriptions.joined(separator: ", ")
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
                Text(title)
                    .font(.subheadline)
                Divider()
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
                HStack {
                    Button("Back", systemImage: "arrow.left.circle") {
                        sliderVisible.toggle()
                        listVisible.toggle()
                    }
                    .padding()
                    Spacer()
                    Button("Cancel", systemImage: "xmark.circle") {
                        sliderVisible.toggle()
                    }
                    Spacer()
                    Button("OK", systemImage: "checkmark.circle") {
                        // Encode to JSON string because API expects String parameter
                        commandParameter.Parameter = hueSatBriModel.tempBriComplete
                        let jsonData = try? JSONEncoder().encode(commandParameter)
                        let jsonString = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                        let encoded = jsonString.data(using: .utf8)?.base64EncodedString() ?? ""
                        let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: encoded)
                        commandIds.append(id)
                        sliderVisible.toggle()
                    }
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
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var commandIds: [String] = []
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    TempBriMulti(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
