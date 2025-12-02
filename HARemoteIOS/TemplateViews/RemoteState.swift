//
//  RemoteState.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 02.12.25.
//

import SwiftUI

struct RemoteState: View {
    var remoteItem: RemoteItem?
    var height: CGFloat = 150
    
    @Binding var remoteStates: [IState]
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil

    RemoteState(remoteItem: remoteItem, height: 150, remoteStates: $remoteStates)
}
