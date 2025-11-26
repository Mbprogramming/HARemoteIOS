//
//  RemoteView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct RemoteView: View {
    @State public var remoteViewModel = RemoteViewModel()
    
    var body: some View {
        let currentRemoteItem = remoteViewModel.currentRemote?.remote

        RemoteItemView(remoteItem: currentRemoteItem)
            .task {
                remoteViewModel.load()
            }
    }
}

#Preview {
    RemoteView()
}
