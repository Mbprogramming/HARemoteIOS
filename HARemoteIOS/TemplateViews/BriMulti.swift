//
//  BriMulti.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.12.25.
//

import SwiftUI

struct BriMulti: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    @State private var listVisible: Bool = false
    
    @State var selection = Set<StringStringTuple>()
    @State private var editMode: EditMode = .active
    
    @State private var hueSatBriModel: HueSatBriTempModel = HueSatBriTempModel()
    
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
            let brightnessGradient = LinearGradient(gradient: Gradient(colors: (0...255).map {
                Color(hue: hueSatBriModel.hueDouble, saturation: 1.0, brightness: Double($0) / 255.0)
            }), startPoint: .leading, endPoint: .trailing)
            
            if let items = remoteItem?.steps {
                VStack{
                    List(items, id: \.self, selection: $selection) {
                        Text($0.item2 ?? "")
                    }
                    .environment(\.editMode, $editMode)
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
                    Spacer()
                    HStack {
                        Button("Cancel", systemImage: "xmark.circle") {
                            listVisible.toggle()
                        }
                        .padding()
                        Spacer()
                        Button("OK", systemImage: "checkmark.circle") {
                            let commandParameter = CommandParameterForMultipleValues()
                            // Collect selected ids and descriptions
                            selection.forEach { tuple in
                                if let id = tuple.item1 {
                                    commandParameter.Ids.append(id)
                                }
                                if let desc = tuple.item2 {
                                    commandParameter.Descriptions.append(desc)
                                }
                            }
                            
                            // Encode to JSON string because API expects String parameter
                            commandParameter.Parameter = hueSatBriModel.briComplete
                            let jsonData = try? JSONEncoder().encode(commandParameter)
                            let jsonString = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                            let encoded = jsonString.data(using: .utf8)?.base64EncodedString() ?? ""
                            let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: encoded)
                            commandIds.append(id)
                            
                            listVisible.toggle()
                        }
                        .padding()
                    }
                }
                .presentationDetents([.medium])

            }
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
    
    BriMulti(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}
