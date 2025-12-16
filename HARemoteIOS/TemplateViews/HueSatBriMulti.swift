//
//  HueSatBriMulti.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.12.25.
//

import SwiftUI

struct HueSatBriMulti: View {
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

    var body: some View {
        RemoteBaseButton(remoteItem: remoteItem, action: {
            hueSatBriModel.setRanges(min: remoteItem?.min ?? "", max: remoteItem?.max ?? "")
            if let state = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice }) {
                hueSatBriModel.setState(state: state)
            }
            
            listVisible.toggle()
        }, remoteStates: $remoteStates)
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
                Text(title)
                    .font(.subheadline)
                Divider()
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
                        commandParameter.Parameter = hueSatBriModel.hueSatBriComplete
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
    
    HueSatBriMulti(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
