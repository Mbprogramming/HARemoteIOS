//
//  RemoteButtonCommandList.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.12.25.
//

import SwiftUI

struct RemoteButtonCommandList: View {
    var remoteItem: RemoteItem?
    var targetHeight: CGFloat = 220
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [HAState]
    @State private var parentHeight: CGFloat = 60.0
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State private var showDeferred: Bool = false
    @State private var deferredType: Int = 0
    @State private var deferredDate: Date = Date()
    @State private var atDate: Date = Date()
    @State private var deferredDevice: String = ""
    @State private var deferredCommand: String = ""
    @State private var deferredDescription: String = ""
    
    private func actionDeferred(date: Date, type: Int) {
        switch type {
        case 0, 1:
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            let delay = (hour * 60 * 60) + (minute * 60)
            let cyclic = (type == 1)
            let id = HomeRemoteAPI.shared.sendCommandDeferred(device: deferredDevice, command: deferredCommand, delay: delay, cyclic: cyclic)
            mainModel.executeCommand(id: id)
        case 2:
            let id = HomeRemoteAPI.shared.sendCommandAt(device: deferredDevice, command: deferredCommand, at: date, repeatValue: .none)
            mainModel.executeCommand(id: id)
        case 3:
            let id = HomeRemoteAPI.shared.sendCommandAt(device: deferredDevice, command: deferredCommand, at: date, repeatValue: .daily)
            mainModel.executeCommand(id: id)
        case 4:
            let id = HomeRemoteAPI.shared.sendCommandAt(device: deferredDevice, command: deferredCommand, at: date, repeatValue: .weekly)
            mainModel.executeCommand(id: id)
        case 5:
            let id = HomeRemoteAPI.shared.sendCommandAt(device: deferredDevice, command: deferredCommand, at: date, repeatValue: .monthly)
            mainModel.executeCommand(id: id)
        default:
            break
        }
    }
    
    var body: some View {
        // Derive current state without side effects
        let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
        // Compute background color from the state (use IState.calculatedColor if available)
        let backgroundColor: Color = {
            if let currentState {
                // If you want to use the provided calculatedColor:
                return currentState.calculatedColor.opacity(0.9)
            } else {
                return Color.primary.opacity(0.3)
            }
        }()
        let background = RoundedRectangle(cornerRadius: 10)
            .fill(.ultraThinMaterial)
            .background(backgroundColor)
            .cornerRadius(10)
        
        Menu {
            if let items = remoteItem?.commandMenuItems {
                ForEach(items, id:\.self.description) { item in
                    ControlGroup {
                        Button(item.description ?? "", action: {
                            let id = HomeRemoteAPI.shared.sendCommand(device: item.device ?? "", command: item.command ?? "")
                            mainModel.executeCommand(id: id)
                        })
                        Button(action: {
                            var components = DateComponents()
                            components.hour = 0
                            components.minute = 5
                            
                            deferredDate = Calendar.current.date(from: components) ?? .now
                            atDate = Date.now.addingTimeInterval(86400)
                            
                            deferredType = 0
                            deferredCommand = item.command ?? ""
                            deferredDevice = item.device ?? ""
                            deferredDescription = item.description ?? ""
                            
                            showDeferred = true
                        }){
                            Image(systemName: "clock")
                        }
                    }
                }
            }
               }
        label: {
           HStack {
               let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
               ButtonTextAndIcon(currentRemoteItem: remoteItem, currentState: currentState, targetHeight: targetHeight - 10, parentHeight: $parentHeight)
                   .padding(5)
           }
           .onGeometryChange(for: CGSize.self) { proxy in
                           proxy.size
                       } action: {
                           parentHeight = $0.height
                       }
           .foregroundColor(colorScheme == .dark ? .white : .black)
           .background(background)
           .cornerRadius(10)
           .shadow(radius: 3)
       }
        .sheet(isPresented: $showDeferred) {
            VStack {
                Text("Delayed Execution of \(deferredDescription)")
                    .font(.headline)
                    .padding()
                HStack{
                    Text("Delay Type:")
                    Spacer()
                    Picker("Delay Type:", selection: $deferredType) {
                        Text("Delay").tag(0)
                        Text("Cyclic").tag(1)
                        Text("At").tag(2)
                        Text("Daily").tag(3)
                        Text("Weekly").tag(4)
                        Text("Monthly").tag(5)
                    }
                    .pickerStyle(.menu)
                    .padding()
                }
                .padding()
            Divider()
                VStack {
                    if deferredType == 0 {
                        DatePicker(
                            "Delay",
                            selection: $deferredDate,
                            displayedComponents: [.hourAndMinute]
                        )
                        .padding()
                        Spacer()
                        HStack {
                            Button("Cancel", systemImage: "xmark.circle") {
                                showDeferred.toggle()
                            }
                            .padding()
                            Spacer()
                            Button("OK", systemImage: "checkmark.circle") {
                                showDeferred = false
                                actionDeferred(date: deferredDate, type: 0)
                            }
                        }
                        .padding()
                    } else {
                        if deferredType == 1 {
                            DatePicker(
                                "Delay",
                                selection: $deferredDate,
                                displayedComponents: [.hourAndMinute]
                            )
                            .padding()
                            Spacer()
                            HStack {
                                Button("Cancel", systemImage: "xmark.circle") {
                                    showDeferred.toggle()
                                }
                                .padding()
                                Spacer()
                                Button("OK", systemImage: "checkmark.circle") {
                                    showDeferred = false
                                    actionDeferred(date: deferredDate, type: 1)
                                }
                            }
                            .padding()
                        } else {
                            if deferredType == 2 {
                                DatePicker(
                                    "At",
                                    selection: $atDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .padding()
                                Spacer()
                                HStack {
                                    Button("Cancel", systemImage: "xmark.circle") {
                                        showDeferred.toggle()
                                    }
                                    .padding()
                                    Spacer()
                                    Button("OK", systemImage: "checkmark.circle") {
                                        showDeferred = false
                                        actionDeferred(date: atDate, type: 2)
                                    }
                                }
                                .padding()
                            } else {
                                if deferredType == 3 {
                                    DatePicker(
                                        "At",
                                        selection: $atDate,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .padding()
                                    Spacer()
                                    HStack {
                                        Button("Cancel", systemImage: "xmark.circle") {
                                            showDeferred.toggle()
                                        }
                                        .padding()
                                        Spacer()
                                        Button("OK", systemImage: "checkmark.circle") {
                                            showDeferred = false
                                            actionDeferred(date: atDate, type: 3)
                                        }
                                    }
                                    .padding()
                                } else {
                                    if deferredType == 4 {
                                        DatePicker(
                                            "At",
                                            selection: $atDate,
                                            displayedComponents: [.date, .hourAndMinute]
                                        )
                                        .padding()
                                        Spacer()
                                        HStack {
                                            Button("Cancel", systemImage: "xmark.circle") {
                                                showDeferred.toggle()
                                            }
                                            .padding()
                                            Spacer()
                                            Button("OK", systemImage: "checkmark.circle") {
                                                showDeferred = false
                                                actionDeferred(date: atDate, type: 4)
                                            }
                                        }
                                        .padding()
                                    } else {
                                        if deferredType == 5 {
                                            DatePicker(
                                                "At",
                                                selection: $atDate,
                                                displayedComponents: [.date, .hourAndMinute]
                                            )
                                            .padding()
                                            Spacer()
                                            HStack {
                                                Button("Cancel", systemImage: "xmark.circle") {
                                                    showDeferred.toggle()
                                                }
                                                .padding()
                                                Spacer()
                                                Button("OK", systemImage: "checkmark.circle") {
                                                    showDeferred = false
                                                    actionDeferred(date: atDate, type: 5)
                                                }
                                            }
                                            .padding()
                                        }
                                    }
                                }
                            }
                        }
                    }
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
    @Previewable @State var remoteStates: [HAState] = []
    var remoteItem: RemoteItem? = nil
    var targetHeight: CGFloat = 60
    
    RemoteButtonCommandList(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}
