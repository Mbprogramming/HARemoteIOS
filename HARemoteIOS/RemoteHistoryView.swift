//
//  RemoteHistoryView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 04.12.25.
//

import SwiftUI
import SwiftData

struct RemoteHistoryViewLine: View {
    var remote1: Remote
    var remote2: Remote? = nil
    var remote3: Remote? = nil
    
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteStates: [IState]
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var isVisible: Bool
    @Binding var orientation: UIDeviceOrientation
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
        
    var body: some View {
        HStack {
            Button(action: {
                remoteStates = []
                currentRemote = remote1
                currentRemoteItem = remote1.remote
                remoteItemStack.removeAll()
                Task {
                    remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                }
                isVisible = false
            }){
                VStack {
                    if remote1.icon != nil {
                        AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: remote1.icon!)
                            .frame(width: 40, height: 40)
                    }
                    Text(remote1.description)
                        .truncationMode(.middle)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .font(.title)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 100, height: 100)
            //.glassEffect(.regular, in: .capsule)
            .buttonStyle(.borderless)
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .padding()
            if let remote2 {
                Button(action: {
                    remoteStates = []
                    currentRemote = remote2
                    currentRemoteItem = remote2.remote
                                        remoteItemStack.removeAll()
                    Task {
                        remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                    }
                    isVisible = false
                }){
                    VStack {
                        if remote2.icon != nil {
                            AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: remote2.icon!)
                                .frame(width: 40, height: 40)
                        }
                        Text(remote2.description)
                            .truncationMode(.middle)
                            .allowsTightening(true)
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)
                            .font(.title)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: 100, height: 100)
                //.glassEffect(.regular, in: .)
                .buttonStyle(.borderless)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .padding()
            }
            if orientation == .landscapeLeft || orientation == .landscapeRight {
                if let remote3 {
                    Button(action: {
                        remoteStates = []
                        currentRemote = remote3
                        currentRemoteItem = remote3.remote
                        remoteItemStack.removeAll()
                        Task {
                            remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                        }
                        isVisible = false
                    }){
                        VStack {
                            if remote3.icon != nil {
                                AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: remote3.icon!)
                                    .frame(width: 40, height: 40)
                            }
                            Text(remote3.description)
                                .truncationMode(.middle)
                                .allowsTightening(true)
                                .lineLimit(1)
                                .minimumScaleFactor(0.3)
                                .font(.title)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: 100, height: 100)
                    //.glassEffect(.regular, in: .)
                    .buttonStyle(.borderless)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .padding()
                }
            }
        }
    }
}

struct RemoteHistoryView: View {
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteStates: [IState]
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var isVisible: Bool
    @Binding var orientation: UIDeviceOrientation

    var remotes : [Remote]

    @Environment(\.mainWindowSize) var mainWindowSize
    
    @Environment(\.modelContext) var modelContext
    
    @Query var remoteHistory: [RemoteHistoryEntry]
    
    func buildRemoteContainer() -> [Remote] {
        let tempHistory = remoteHistory.sorted { $0.lastUsed > $1.lastUsed }
        var result: [Remote] = []
        for remote in tempHistory {
            if let r = remotes.first(where: { $0.id == remote.remoteId }) {
                result.append(r)
            }
        }
        return result
    }
    
    var body: some View {
        GlassEffectContainer {
            VStack {
                let remoteList = buildRemoteContainer()
                if remoteList.isEmpty {
                    Text("No remotes found")
                        .padding()
                }
                if orientation == .landscapeLeft || orientation == .landscapeRight {
                    ForEach(Array(stride(from: 0, to: remoteList.count, by: 3)), id: \.self) { i in
                        let remote1 = remoteList[i]
                        let remote2 = (i + 1 < remoteList.count) ? remoteList[i + 1] : nil
                        let remote3 = (i + 2 < remoteList.count) ? remoteList[i + 2] : nil
                        RemoteHistoryViewLine(remote1: remote1, remote2: remote2, remote3: remote3, currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $isVisible, orientation: $orientation)
                    }
                } else {
                    ForEach(Array(stride(from: 0, to: remoteList.count, by: 2)), id: \.self) { i in
                        let remote1 = remoteList[i]
                        let remote2 = (i + 1 < remoteList.count) ? remoteList[i + 1] : nil
                        RemoteHistoryViewLine(remote1: remote1, remote2: remote2, remote3: nil, currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $isVisible, orientation: $orientation)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var currentRemote: Remote? = nil
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var remoteStates: [IState] = []
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var isVisible: Bool = true
    @Previewable @State var orientation: UIDeviceOrientation = UIDeviceOrientation.portrait
    
    var remotes : [Remote] = []
    
    RemoteHistoryView(currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $isVisible, orientation: $orientation, remotes: remotes)
}
