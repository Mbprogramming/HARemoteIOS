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

    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteStates: [IState]
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var isVisible: Bool
    
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \RemoteHistoryEntry.lastUsed, order: .reverse) var remoteHistory: [RemoteHistoryEntry]
    
    func delete(indexSet: IndexSet) {
        for i in indexSet {
            let remoteHistoryItem = remoteHistory[i]
            modelContext.delete(remoteHistoryItem)
        }
    }
    
    var body: some View {
        HStack {
            Button(action: {
                remoteStates = []
                currentRemote = remote1
                currentRemoteItem = remote1.remote
                
                let itemToUpdate = remoteHistory.first(where: { $0.remoteId == currentRemote?.id ?? "" })
                if itemToUpdate != nil {
                    itemToUpdate?.lastUsed = Date()
                } else {
                    modelContext.insert(RemoteHistoryEntry(remoteId: currentRemote?.id ?? ""))
                }
                if remoteHistory.count > 6 {
                    let indexSet = IndexSet(remoteHistory.indices.prefix(remoteHistory.count - 6))
                    delete(indexSet: indexSet)
                }
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
            .glassEffect(.regular, in: .capsule)
            .buttonStyle(.glass)
            .padding()
        if let remote2 {
            Button(action: {
                remoteStates = []
                currentRemote = remote2
                currentRemoteItem = remote2.remote
                
                let itemToUpdate = remoteHistory.first(where: { $0.remoteId == currentRemote?.id ?? "" })
                if itemToUpdate != nil {
                    itemToUpdate?.lastUsed = Date()
                } else {
                    modelContext.insert(RemoteHistoryEntry(remoteId: currentRemote?.id ?? ""))
                }
                if remoteHistory.count > 6 {
                    let indexSet = IndexSet(remoteHistory.indices.prefix(remoteHistory.count - 6))
                    delete(indexSet: indexSet)
                }
                remoteItemStack.removeAll()
                Task {
                    remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                }
                isVisible = false
            }){
                VStack {
                    if remote1.icon != nil {
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
            .glassEffect(.regular, in: .capsule)
            .buttonStyle(.glass)
            .padding()
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
    
    var remotes : [Remote]

    @Environment(\.mainWindowSize) var mainWindowSize
    
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \RemoteHistoryEntry.lastUsed, order: .reverse) var remoteHistory: [RemoteHistoryEntry]
    
    func buildRemoteContainer() -> [Remote] {
        remotes.compactMap { remote in
            // If the remote's id matches any history entry, include it.
            // Adjust matching logic if you want unique ordering or a 1:1 mapping
            if remoteHistory.contains(where: { $0.remoteId == remote.id }) {
                return remote
            } else {
                return nil
            }
        }
    }
    
    var body: some View {
        GlassEffectContainer {
            VStack {
                let remoteList = buildRemoteContainer()
                if remoteList.isEmpty {
                    Text("No remotes found")
                        .padding()
                }
                ForEach(Array(stride(from: 0, to: remoteList.count, by: 2)), id: \.self) { i in
                    let remote1 = remoteList[i]
                    let remote2 = (i + 1 < remoteList.count) ? remoteList[i + 1] : nil
                    RemoteHistoryViewLine(remote1: remote1, remote2: remote2, currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $isVisible)
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
    
    var remotes : [Remote] = []
    RemoteHistoryView(currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $isVisible, remotes: remotes)
}
