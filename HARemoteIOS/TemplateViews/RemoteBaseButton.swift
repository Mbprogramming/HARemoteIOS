//
//  RemoteBaseButton.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 16.12.25.
//

import SwiftUI

struct RemoteBaseButton: View {
    @Binding var remoteStates: [IState]
    
    private let action: () -> Void
    private var remoteItem: RemoteItem?

    init(remoteItem: RemoteItem?,
         action: @escaping () -> Void,
         remoteStates: Binding<[IState]>) {
        self.remoteItem = remoteItem
        self.action = action
        self._remoteStates = remoteStates
    }
    
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
        Button(action: action) {
            HStack {
                ButtonTextAndIcon(currentRemoteItem: remoteItem, currentState: currentState)
                if remoteItem?.template == RemoteTemplate.List
                    || remoteItem?.template == RemoteTemplate.Wrap
                    || remoteItem?.template == RemoteTemplate.Grid3X4
                    || remoteItem?.template == RemoteTemplate.Grid4X5
                    || remoteItem?.template == RemoteTemplate.Grid5x3 {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.footnote)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .background(background)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

#Preview {
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    RemoteBaseButton(remoteItem: remoteItem, action: { return }, remoteStates: $remoteStates)
}
