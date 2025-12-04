//
//  SidePaneView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI
import SwiftData

struct HeaderView: View {
    private var zoneContent: Zone?
    
    init(zone: Zone?) {
        zoneContent = zone
    }
    
    var body: some View {
        if zoneContent == nil {
            Text("Unknown zone")
        } else {
            HStack {
                if let iconId = zoneContent?.icon {
                    AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: iconId)
                        .frame(width: 40, height: 40)
                }
                Text(zoneContent?.description ?? "Unknown zone")
            }
        }
    }
}

struct ItemView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \RemoteHistoryEntry.lastUsed, order: .forward) var remoteHistory: [RemoteHistoryEntry]
    
    public var remote: Remote
    
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var remoteStates: [IState]
    @Binding var isVisible: Bool
    
    func delete(indexSet: IndexSet) {
        for i in indexSet {
            let remoteHistoryItem = remoteHistory[i]
            modelContext.delete(remoteHistoryItem)
        }
    }
    
    var body: some View {
        HStack {
            if let iconId = remote.icon {
                AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: iconId)
                    .frame(width: 40, height: 40)
            }
            Text(remote.description)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            remoteStates = []
            currentRemote = remote
            currentRemoteItem = remote.remote
            
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
        }
    }
}

struct SidePaneView: View {
    @Environment(\.remotes) var remotes
    @Environment(\.zones) var zones
    
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var remoteStates: [IState]
    @Binding var isVisible: Bool

    var body: some View {
        // Precompute visible zones to keep the builder simple
        let visibleZones: [Zone] = zones.filter { $0.isVisible == true }
        NavigationView {
            TabView {
                VStack{
                    
                }.tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
                List {
                    ForEach(visibleZones) { zone in
                        // Map zone.remoteIds to concrete Remote models up front
                        let zoneRemotes: [Remote] = {
                            guard let ids = zone.remoteIds else { return [] }
                            let set = Set(ids)
                            return remotes.filter { set.contains($0.id) }
                        }()
                        
                        Section(header: HeaderView(zone: zone)) {
                            ForEach(zoneRemotes) { remote in
                                ItemView(
                                    remote: remote,
                                    currentRemote: $currentRemote,
                                    currentRemoteItem: $currentRemoteItem,
                                    remoteItemStack: $remoteItemStack,
                                    remoteStates: $remoteStates,
                                    isVisible: $isVisible
                                )
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Zones", systemImage: "square.split.bottomrightquarter.fill")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Back", systemImage: "arrow.down"){
                        isVisible = false
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var currentRemote: Remote? = nil
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var remoteStates: [IState] = []
    @Previewable @State var isVisible: Bool = true
    
    SidePaneView(
        currentRemote: $currentRemote,
        currentRemoteItem: $currentRemoteItem,
        remoteItemStack: $remoteItemStack,
        remoteStates: $remoteStates,
        isVisible: $isVisible
    )
}

