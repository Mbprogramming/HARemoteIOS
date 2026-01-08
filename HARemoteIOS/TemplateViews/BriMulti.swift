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
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [IState]
    
    @State private var listVisible: Bool = false
    
    @State var selection = Set<StringStringTuple>()
    @State private var editMode: EditMode = .active
    
    @State private var hueSatBriModel: HueSatBriTempModel = HueSatBriTempModel()
    
    @State private var delay: Date? = nil
    @State private var delayType: Int? = nil
    

    var body: some View {
        RemoteBaseButton(remoteItem: remoteItem, action: {
            hueSatBriModel.setRanges(min: remoteItem?.min ?? "", max: remoteItem?.max ?? "")
            if let state = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice }) {
                hueSatBriModel.setState(state: state)
            }
            
            listVisible.toggle()
        }, actionDeferred: { (date: Date, type: Int) in
            delay = date
            delayType = type
            hueSatBriModel.setRanges(min: remoteItem?.min ?? "", max: remoteItem?.max ?? "")
            if let state = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice }) {
                hueSatBriModel.setState(state: state)
            }
            
            listVisible.toggle()
        }, remoteStates: $remoteStates)
        .sheet(isPresented: $listVisible) {
            let brightnessGradient = LinearGradient(gradient: Gradient(colors: (0...255).map {
                Color(hue: hueSatBriModel.hueDouble, saturation: 1.0, brightness: Double($0) / 255.0)
            }), startPoint: .leading, endPoint: .trailing)
            
            if let items = remoteItem?.steps {
                VStack{
                    HStack {
                        Button("All", systemImage: "plus.circle") {
                            selection.removeAll()
                            for itemEntry in items {
                                selection.insert(itemEntry)
                            }
                        }
                        Spacer()
                        Button("None", systemImage: "minus.circle") {
                            selection.removeAll()
                        }
                    }
                    .padding()
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
                            if delay != nil && delayType != nil {
                                if delayType! == 0 {
                                    let hour = Calendar.current.component(.hour, from: delay!)
                                    let minute = Calendar.current.component(.minute, from: delay!)
                                    let delay = (hour * 60 * 60) + (minute * 60)
                                    let id = HomeRemoteAPI.shared.sendCommandDeferredParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: encoded, delay: delay, cyclic: false)
                                    mainModel.executeCommand(id: id)
                                } else {
                                    if delayType! == 1 {
                                        let hour = Calendar.current.component(.hour, from: delay!)
                                        let minute = Calendar.current.component(.minute, from: delay!)
                                        let delay = (hour * 60 * 60) + (minute * 60)
                                        let id = HomeRemoteAPI.shared.sendCommandDeferredParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: encoded, delay: delay, cyclic: true)
                                        mainModel.executeCommand(id: id)
                                    } else {
                                        if delayType! == 2 {
                                            let id = HomeRemoteAPI.shared.sendCommandAtParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: encoded, at: delay!, repeatValue: .none)
                                            mainModel.executeCommand(id: id)
                                        } else {
                                            if delayType! == 3 {
                                                let id = HomeRemoteAPI.shared.sendCommandAtParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: encoded, at: delay!, repeatValue: .daily)
                                                mainModel.executeCommand(id: id)
                                            } else {
                                                if delayType! == 4 {
                                                    let id = HomeRemoteAPI.shared.sendCommandAtParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: encoded, at: delay!, repeatValue: .weekly)
                                                    mainModel.executeCommand(id: id)
                                                } else {
                                                    if delayType! == 5 {
                                                        let id = HomeRemoteAPI.shared.sendCommandAtParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: encoded, at: delay!, repeatValue: .monthly)
                                                        mainModel.executeCommand(id: id)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                            } else {
                                let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: encoded)
                                mainModel.executeCommand(id: id)
                            }
                            
                            listVisible.toggle()
                        }
                        .padding()
                    }
                }
                .presentationDetents([.medium])

            }
        }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    BriMulti(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}
