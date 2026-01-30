//
//  RemoteStateView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 30.01.26.
//

import SwiftUI

struct RemoteStateViewItem: View {
    var device: String = ""
    var state: String = ""
    
    @Binding var mainModel: RemoteMainModel
    
    var body: some View {
        Group {
            if let stateItem = mainModel.remoteStates.first(where: { $0.device == device && $0.id == state }) {
                HStack {
                    if let icon = stateItem.icon {
                        AsyncServerImage(imageWidth: 20, imageHeight: 20, imageId: icon)
                            .frame(width: 20, height: 20)
                    }
                    Text(stateItem.convertedValue ?? stateItem.value ?? "")
                        .truncationMode(.middle)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                }
            } else {
                EmptyView()
            }
        }
    }
}

struct RemoteStateView: View {
    @Binding var mainModel: RemoteMainModel
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        Group {
            if let remote = mainModel.currentRemote, let states = remote.defaultState {
                let width = mainWindowSize.width / CGFloat(states.count)
                HStack {
                    ForEach(states.indices, id: \.self) { i in
                        let state = states[i]
                        let device = state.item1
                        let stateId = state.item2
                        if let device, let stateId {
                            RemoteStateViewItem(device: device, state: stateId, mainModel: $mainModel)
                                .frame(width: width, height: 50)
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    @Previewable @State var mainModel = RemoteMainModel()
    
    RemoteStateView(mainModel: $mainModel)
}
