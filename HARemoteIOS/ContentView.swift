//
//  ContentView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 21.11.25.
//

import SwiftUI
import SwiftData
import SignalRClient


private struct MainWindowSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

private struct ZonesCollection: EnvironmentKey {
    static let defaultValue: [Zone] = []
}

private struct RemotesCollection: EnvironmentKey {
    static let defaultValue: [Remote] = []
}

private struct CommandIdCollection: EnvironmentKey {
    static let defaultValue: [String] = []
}

extension EnvironmentValues {
    var mainWindowSize: CGSize {
        get { self[MainWindowSizeKey.self] }
        set { self[MainWindowSizeKey.self] = newValue }
    }
    var zones: [Zone] {
        get { self[ZonesCollection.self] }
        set { self[ZonesCollection.self] = newValue }
    }
    var remotes: [Remote] {
        get { self[RemotesCollection.self] }
        set { self[RemotesCollection.self] = newValue }
    }
    var commandIds: [String] {
        get { self[CommandIdCollection.self] }
        set { self[CommandIdCollection.self] = newValue }
    }
}

struct ContentView: View {
    @State private var navigateToSettings: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showSmallPopup: Bool = false
    @State private var showSmallPopup2: Bool = false
    @State private var showSidePane: Bool = false
    @State private var isLoading: Bool = false

    @State private var zones: [Zone] = []
    @State private var remotes : [Remote] = []
    @State private var mainCommands: [RemoteItem] = []
    @State private var commandIds: [String] = []
    @State private var remoteStates: [IState] = []

    @State private var currentRemote: Remote? = nil
    @State private var currentRemoteItem: RemoteItem? = nil
    @State private var remoteItemStack: [RemoteItem] = []
    
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \RemoteHistoryEntry.lastUsed, order: .reverse) var remoteHistory: [RemoteHistoryEntry]

    @State private var connection: HubConnection?
    
    private func openUrl(id: String, device: String, command: String, url: String) async {
        return
    }
    
    private func stateChanged(device: String, state: String, value: String, convertedValue: String, icon: String, color: Int64?, lastChange: String) async {
        // If no matching state exists, nothing to do quickly
        guard remoteStates.contains(where: { $0.device == device && $0.id == state }) else { return }
        
        DispatchQueue.main.async {
            // Rebuild the array by replacing only the matching item with a new IState instance
            let updated: [IState] = remoteStates.map { s in
                if s.device == device && s.id == state {
                    return IState(
                        id: s.id,
                        device: s.device,
                        value: value,
                        convertedValue: convertedValue,
                        color: color,
                        icon: icon,
                        convertDescription: s.convertDescription,
                        nativeType: s.nativeType,
                        showValueAndIcon: s.showValueAndIcon,
                        stateToIcon: s.stateToIcon,
                        stateToColor: s.stateToColor,
                        isCombined: s.isCombined,
                        additionalText: s.additionalText
                    )
                } else {
                    return s
                }
            }
            remoteStates = updated
        }
    }

    private func setupConnection() async throws {
        guard connection == nil else {
            return
        }
        
        connection = HubConnectionBuilder()
            .withUrl(url: "http://192.168.5.106:5000/homeautomation")
            .withAutomaticReconnect()
            .withLogLevel(logLevel: LogLevel.debug)
            .build()

        await connection!.on("OpenUrl", handler:openUrl)
        await connection!.on("StateChanged", handler:stateChanged)

        try await connection!.start()
    }
    
    var body: some View {
        GeometryReader { geo in
            if isLoading {
                ProgressView()
            }
            NavigationStack {
                TabView {
                    NavigationView {
                        if currentRemoteItem?.template == RemoteTemplate.List ||
                            currentRemoteItem?.template == RemoteTemplate.Wrap {
                            RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                                .ignoresSafeArea()
                        } else {
                            RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                        }
                    }
                    .tabItem {
                        Label("Remote", systemImage: "av.remote")
                    }

                    NavigationView {
                        StateView(remoteStates: $remoteStates)
                            .ignoresSafeArea()
                    }
                    .tabItem {
                        Label("States", systemImage: "flag")
                    }

                    NavigationView {
                        HistoryView(commandIds: $commandIds)
                            .ignoresSafeArea()
                    }
                    .tabItem {
                        Label("History", systemImage: "checklist")
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button("Remote History", systemImage: "list.bullet.badge.ellipsis"){
                            showSmallPopup2 = true
                        }
                        .popover(isPresented: $showSmallPopup2) {
                            RemoteHistoryView(currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $showSmallPopup2, remotes: remotes)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Main Commands", systemImage: "square.grid.3x3.square.badge.ellipsis") {
                            showSmallPopup = true
                        }
                        .popover(isPresented: $showSmallPopup) {
                            MainCommandsView(mainCommands: $mainCommands,
                                             currentRemoteItem: $currentRemoteItem,
                                             remoteItemStack: $remoteItemStack,
                                             commandIds: $commandIds,
                                             isVisible: $showSmallPopup)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Home", systemImage: "house") {
                            showSidePane = true
                        }
                        .fullScreenCover(isPresented: $showSidePane) {
                            SidePaneView(currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, remoteStates: $remoteStates, isVisible: $showSidePane)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back", systemImage: "arrow.left") {
                            if remoteItemStack.count > 0 {
                                currentRemoteItem = remoteItemStack.popLast()
                            }
                        }
                        .disabled(remoteItemStack.count <= 0)
                    }
                    ToolbarItem(placement: .principal) {
                        Text(currentRemote?.description ?? "Remote")
                            .font(.headline)
                    }
                }.ignoresSafeArea()
            }
            .task {
                isLoading = true
                do {
                    zones = try await HomeRemoteAPI.shared.getZonesComplete()
                    remotes = try await HomeRemoteAPI.shared.getRemotes()
                    mainCommands = try await HomeRemoteAPI.shared.getMainCommands()
                    if let lastRemote = remoteHistory.first {
                        if let lastRemoteItem = remotes.first(where: {$0.id == lastRemote.remoteId}){
                            remoteStates = []
                            currentRemote = lastRemoteItem
                            currentRemoteItem = lastRemoteItem.remote
                            
                            let itemToUpdate = remoteHistory.first(where: { $0.remoteId == currentRemote?.id ?? "" })
                            if itemToUpdate != nil {
                                itemToUpdate?.lastUsed = Date()
                            }
                            remoteItemStack.removeAll()
                            Task {
                                remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                            }                            
                        }
                    }
                    try await setupConnection()
                } catch {
                    
                }
                isLoading = false;
            }
            // Provide window size via environment
            .environment(\.mainWindowSize, geo.size)
            .environment(\.zones, zones)
            .environment(\.remotes, remotes)
            .environment(\.commandIds, commandIds)
        }
    }
}

#Preview {
    ContentView()
}
