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
        let currentRemoteTitle = remoteViewModel.currentRemote?.description ?? "Unknown"
        let currentRemoteItem = remoteViewModel.currentRemote?.remote
        let template = currentRemoteItem?.template?.rawValue ?? "Unknown"
        VStack {
            Text(template)
            Text(currentRemoteTitle)
        }
        .padding()
        .task {
            remoteViewModel.load()
        }
    }
}

#Preview {
    RemoteView()
}
