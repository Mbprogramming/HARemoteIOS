//
//  ContentView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 21.11.25.
//

import SwiftUI

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
    @State private var isLoading: Bool = false

    @State private var zones: [Zone] = []
    @State private var remotes : [Remote] = []
    @State private var mainCommands: [RemoteItem] = []
    @State private var commandIds: [String] = []

    @State private var currentRemote: Remote? = nil
    @State private var currentRemoteItem: RemoteItem? = nil
    @State private var remoteItemStack: [RemoteItem] = []
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
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
                            RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds)
                                .ignoresSafeArea()
                        } else {
                            RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds)
                        }
                    }
                    .tabItem {
                        Label("Remote", systemImage: "av.remote")
                    }
                    .background(
                        NavigationLink("", destination: SidePaneView(currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem,
                            remoteItemStack: $remoteItemStack), isActive: $navigateToHome)
                            .hidden()
                    )

                    NavigationView {
                        StateView()
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Settings", systemImage: "gear") {
                            showSmallPopup = true
                        }
                        .popover(isPresented: $showSmallPopup) {
                            MainCommandsView(mainCommands: $mainCommands,
                                             currentRemoteItem: $currentRemoteItem,
                                             remoteItemStack: $remoteItemStack,
                                             commandIds: $commandIds)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Home", systemImage: "house") {
                            navigateToHome = true
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

