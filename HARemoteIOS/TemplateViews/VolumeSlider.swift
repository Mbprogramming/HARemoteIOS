//
//  VolumeSlider.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.12.25.
//

import SwiftUI

struct VolumeSlider: View {
    var remoteItem: RemoteItem?
    var targetHeight: CGFloat = 220
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [HAState]
    
    @State private var sliderVisible: Bool = false
    @State private var min: Int = 0
    @State private var max: Int = 100
    @State private var value: Int = 50
    @State private var angleForStep: Int = 20
    @State private var step: Int = 1
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    @State private var delay: Date? = nil
    @State private var delayType: Int? = nil
    
    var body: some View {
        RemoteBaseButton(remoteItem: remoteItem, targetHeight: targetHeight, action: {
            if let rmMin = remoteItem?.min, let rmMax = remoteItem?.max, let rmStep = remoteItem?.step {
                min = Int(rmMin) ?? 0
                max = Int(rmMax) ?? 100
                step = Int(rmStep) ?? 1
            }
            if let state = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice }), let v = state.value {
                value = Int(v) ?? 50
            } else {
                value = 50
            }
            sliderVisible.toggle()
        }, actionDeferred: { (date: Date, type: Int) in
            delay = date
            delayType = type
            if let rmMin = remoteItem?.min, let rmMax = remoteItem?.max, let rmStep = remoteItem?.step {
                min = Int(rmMin) ?? 0
                max = Int(rmMax) ?? 100
                step = Int(rmStep) ?? 1
            }
            if let state = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice }), let v = state.value {
                value = Int(v) ?? 50
            } else {
                value = 50
            }
            sliderVisible.toggle()
        }, remoteStates: $remoteStates)
        .popover(isPresented: $sliderVisible,
                 attachmentAnchor: .point(.center), // Ankerpunkt des Popovers relativ zum Button
                 arrowEdge: .top) {
            VStack{
                VolumeKnob(minValue: $min, maxValue: $max, angleForStep: $angleForStep, currentValue: $value, step: $step)
                    .padding()
                HStack {
                    Button("Cancel", systemImage: "xmark.circle") {
                        sliderVisible.toggle()
                    }
                    .padding()
                    Spacer()
                    Button("OK", systemImage: "checkmark.circle") {
                        if delay != nil && delayType != nil {
                            if delayType! == 0 {
                                let hour = Calendar.current.component(.hour, from: delay!)
                                let minute = Calendar.current.component(.minute, from: delay!)
                                let delay = (hour * 60 * 60) + (minute * 60)
                                let id = HomeRemoteAPI.shared.sendCommandDeferredParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: "\(value)", delay: delay, cyclic: false)
                                mainModel.executeCommand(id: id)
                            } else {
                                if delayType! == 1 {
                                    let hour = Calendar.current.component(.hour, from: delay!)
                                    let minute = Calendar.current.component(.minute, from: delay!)
                                    let delay = (hour * 60 * 60) + (minute * 60)
                                    let id = HomeRemoteAPI.shared.sendCommandDeferredParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: "\(value)", delay: delay, cyclic: true)
                                    mainModel.executeCommand(id: id)
                                } else {
                                    if delayType! == 2 {
                                        let id = HomeRemoteAPI.shared.sendCommandAtParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: "\(value)", at: delay!, repeatValue: .none)
                                        mainModel.executeCommand(id: id)
                                    } else {
                                        if delayType! == 3 {
                                            let id = HomeRemoteAPI.shared.sendCommandAtParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: "\(value)", at: delay!, repeatValue: .daily)
                                            mainModel.executeCommand(id: id)
                                        } else {
                                            if delayType! == 4 {
                                                let id = HomeRemoteAPI.shared.sendCommandAtParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: "\(value)", at: delay!, repeatValue: .weekly)
                                                mainModel.executeCommand(id: id)
                                            } else {
                                                if delayType! == 5 {
                                                    let id = HomeRemoteAPI.shared.sendCommandAtParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: "\(value)", at: delay!, repeatValue: .monthly)
                                                    mainModel.executeCommand(id: id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                        } else {
                            let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: "\(value)")
                            mainModel.executeCommand(id: id)
                        }
                        
                        sliderVisible.toggle()
                    }
                    .padding()
                }
            }
            .padding()
            .frame(minWidth: mainWindowSize.width - 20)
            .presentationCompactAdaptation(.popover)
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
    
    VolumeSlider(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}
