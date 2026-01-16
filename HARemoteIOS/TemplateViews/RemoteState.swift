//
//  RemoteState.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 02.12.25.
//

import SwiftUI

struct RemoteStateItemView: View {
    var state: IState
    var targetHeight: CGFloat = 220
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        // Compute background color from the state (use IState.calculatedColor if available)
        let backgroundColor: Color = {
            return state.calculatedColor.opacity(0.9)
        }()
        let background = RoundedRectangle(cornerRadius: 10)
            .fill(.ultraThinMaterial)
            .background(backgroundColor)
            .cornerRadius(10)
        VStack {
            if state.showImage == true {
                AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: state.icon!)
                    .frame(width: 40, height: 40)
            }
            if state.showText == true {
                Text(state.completeValue)
                    .truncationMode(.middle)
                    .allowsTightening(true)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .font(.title)
            }
            Spacer()
            HStack {
                Text("\(state.device ?? "") \(state.id ?? "")")
                    .font(.footnote)
                    .lineLimit(1)
                    .truncationMode(.head)
                Spacer()
            }
        }
        .padding()
        .frame(height: targetHeight)
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .background(background)
        .cornerRadius(10)
    }
}

struct RemoteState: View {
    var remoteItem: RemoteItem?
    var targetHeight: CGFloat = 220
    
    @Binding var remoteStates: [IState]
    
    var body: some View {
        let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
        if currentState != nil {
            RemoteStateItemView(state: currentState!, targetHeight: targetHeight)
        }
    }
}

#Preview {
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    RemoteState(remoteItem: remoteItem, targetHeight: 60, remoteStates: $remoteStates)
}
