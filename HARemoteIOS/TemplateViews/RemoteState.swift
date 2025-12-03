//
//  RemoteState.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 02.12.25.
//

import SwiftUI

struct RemoteStateItemView: View {
    var state: IState
        
    var body: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(state.calculatedColor)
        )
    }
}

struct RemoteState: View {
    var remoteItem: RemoteItem?
    var height: CGFloat = 150
    
    @Binding var remoteStates: [IState]
    
    var body: some View {
        let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
        if currentState != nil {
            RemoteStateItemView(state: currentState!)
                .frame(maxWidth: .infinity, maxHeight: height)
        }
    }
}

#Preview {
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil

    RemoteState(remoteItem: remoteItem, height: 150, remoteStates: $remoteStates)
}
