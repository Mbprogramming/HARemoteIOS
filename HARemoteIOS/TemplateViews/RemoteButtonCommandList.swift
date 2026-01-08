//
//  RemoteButtonCommandList.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.12.25.
//

import SwiftUI

struct RemoteButtonCommandList: View {
    var remoteItem: RemoteItem?
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [IState]
    @State private var parentHeight: CGFloat = 60.0
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @State private var delay: Date? = nil
    @State private var delayType: Int? = nil
    
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
                    Button(item.description ?? "", action: {
                        let id = HomeRemoteAPI.shared.sendCommand(device: item.device ?? "", command: item.command ?? "")
                        mainModel.executeCommand(id: id)
                    })
                }
            }
               }
        label: {
           HStack {
               let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
               ButtonTextAndIcon(currentRemoteItem: remoteItem, currentState: currentState, parentHeight: $parentHeight)
                   .padding()
           }
           .onGeometryChange(for: CGSize.self) { proxy in
                           proxy.size
                       } action: {
                           parentHeight = $0.height
                       }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
           .foregroundColor(colorScheme == .dark ? .white : .black)
           .background(background)
           .cornerRadius(10)
           .shadow(radius: 3)
       }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    RemoteButtonCommandList(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}
