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
    
    private func deleteHistory(indexSet: IndexSet) {
        for i in indexSet {
            let remoteHistoryItem = remoteHistory[i]
            modelContext.delete(remoteHistoryItem)
        }
    }
    
    private func isFavorite(remoteId: String) -> Bool {
        let descriptor = FetchDescriptor<RemoteFavorite>(
            predicate: #Predicate { $0.remoteId == remoteId }
        )
        do {
            let favorites = try modelContext.fetch(descriptor)
            return favorites.isEmpty == false
        } catch {
            return false
        }
    }
    
    private func toggleFavorite(remoteId: String) {
        let descriptor = FetchDescriptor<RemoteFavorite>(
            predicate: #Predicate { $0.remoteId == remoteId }
        )
        do {
            let favorites = try modelContext.fetch(descriptor)
            if let existing = favorites.first {
                modelContext.delete(existing)
            } else {
                modelContext.insert(RemoteFavorite(remoteId: remoteId))
            }
            try? modelContext.save()
        } catch {
            // Swallow errors for now; you might add logging/UI later.
        }
    }
    
    var body: some View {
        let favorite = isFavorite(remoteId: remote.id)
        
        HStack {
            if let iconId = remote.icon {
                AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: iconId)
                    .frame(width: 40, height: 40)
            }
            Text(remote.description)
            Spacer()
            if favorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption2)
                    .bold()
            }
            Image(systemName: "chevron.right")
                .font(.caption2)
                .bold()
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .leading) {
            Button("Favorite", systemImage: favorite ? "star" : "star.fill") {
                toggleFavorite(remoteId: remote.id)
            }
            .tint(favorite ? Color.gray : Color.yellow)
        }
        .onTapGesture {
            remoteStates = []
            currentRemote = remote
            
            let itemToUpdate = remoteHistory.first(where: { $0.remoteId == currentRemote?.id ?? "" })
            if itemToUpdate != nil {
                itemToUpdate?.lastUsed = Date()
            } else {
                modelContext.insert(RemoteHistoryEntry(remoteId: currentRemote?.id ?? ""))
            }
            if remoteHistory.count > 6 {
                let indexSet = IndexSet(remoteHistory.indices.prefix(remoteHistory.count - 6))
                deleteHistory(indexSet: indexSet)
            }
            remoteItemStack.removeAll()
            Task {
                remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
            }
            try? modelContext.save()
            isVisible = false
        }
    }
}

struct SidePaneView: View {
    @Environment(\.remotes) var remotes
    @Environment(\.zones) var zones
    @Environment(\.modelContext) var modelContext

    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var remoteStates: [IState]
    @Binding var isVisible: Bool
    
    @State private var expandedZones: Set<String> = []

    private func isFavorite(remoteId: String) -> Bool {
        let descriptor = FetchDescriptor<RemoteFavorite>(
            predicate: #Predicate { $0.remoteId == remoteId }
        )
        do {
            let favorites = try modelContext.fetch(descriptor)
            return favorites.isEmpty == false
        } catch {
            return false
        }
    }
    
    var body: some View {
        // Precompute visible zones to keep the builder simple
        let visibleZones: [Zone] = zones.filter { $0.isVisible == true }
        NavigationView {
            TabView {
                    List {
                        ForEach(remotes) { remote in
                            let favorite = isFavorite(remoteId: remote.id)
                            if favorite {
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
                        
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedZones.contains(zone.id) },
                                set: { newValue in
                                    if newValue {
                                        expandedZones.insert(zone.id)
                                    } else {
                                        expandedZones.remove(zone.id)
                                    }
                                }
                            )
                        ) {
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
                        } label: {
                            HeaderView(zone: zone)
                        }
                    }
                }
                .tabItem {
                    Label("Zones", systemImage: "square.split.bottomrightquarter.fill")
                }
                UserSettings()
                    .tabItem{
                        Label("Settings", systemImage: "gear")
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Back", systemImage: "chevron.down"){
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
