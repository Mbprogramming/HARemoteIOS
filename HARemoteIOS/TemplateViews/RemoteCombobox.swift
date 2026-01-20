//
//  RemoteCombobox.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 16.12.25.
//

import SwiftUI

struct RemoteCombobox: View {
    var remoteItem: RemoteItem?
    var targetHeight: CGFloat = 220
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [HAState]
    @State private var parentHeight: CGFloat = 60.0
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
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
            if let items = remoteItem?.steps {
                ForEach(items, id:\.self.item1) { item in
                    Button(item.item2 ?? "", action: {
                        let id = HomeRemoteAPI.shared.sendCommandParameter(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "", parameter: item.item1 ?? "")
                        mainModel.executeCommand(id: id)
                    })
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
           .padding(3)
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
    
    RemoteCombobox(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}
