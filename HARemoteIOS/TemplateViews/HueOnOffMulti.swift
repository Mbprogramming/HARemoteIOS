//
//  HueOnOffMulti.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.12.25.
//

import SwiftUI

struct HueOnOffMulti: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [IState]
    
    @State private var listVisible: Bool = false
    
    @State var selection = Set<StringStringTuple>()
    @State private var editMode: EditMode = .active
    
    @State private var delay: Date? = nil
    @State private var delayType: Int? = nil
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        RemoteBaseButton(remoteItem: remoteItem, action: {
            listVisible.toggle()
        }, actionDeferred: { (date: Date, type: Int) in
            delay = date
            delayType = type
            listVisible.toggle()
        }, remoteStates: $remoteStates)
        .sheet(isPresented: $listVisible) {
            if let items = remoteItem?.steps {
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
                }.tint(.none)
                .environment(\.editMode, $editMode)
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
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    HueOnOffMulti(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}
