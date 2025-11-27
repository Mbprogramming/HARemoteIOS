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
}

struct ContentView: View {
    @State private var navigateToSettings: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showSmallPopup: Bool = false

    @State private var zones: [Zone] = []
    @State private var remotes : [Remote] = []

    @State private var currentRemote: Remote? = nil
    @State private var currentRemoteItem: RemoteItem? = nil
    @State private var remoteItemStack: [RemoteItem] = []

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                TabView {
                    NavigationView {
                        RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack)
                            .ignoresSafeArea()
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
                        HistoryView()
                            .ignoresSafeArea()
                    }
                    .tabItem {
                        Label("History", systemImage: "checklist")
                    }
                }
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Settings", systemImage: "gear") {
                            showSmallPopup = true
                        }
                        .popover(isPresented: $showSmallPopup, arrowEdge: .top) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Quick Settings")
                                    .font(.headline)
                                Button("Go to Settings") {
                                    navigateToSettings = true
                                    showSmallPopup = false
                                }
                                Button("Close") {
                                    showSmallPopup = false
                                }
                            }
                            .padding()
                            .frame(maxWidth: 280)
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
                }
            }
            .task {
                do {
                    zones = try await HomeRemoteAPI.shared.getZonesComplete()
                    remotes = try await HomeRemoteAPI.shared.getRemotes()
                } catch {
                    
                }
            }
            // Provide window size via environment
            .environment(\.mainWindowSize, geo.size)
            .environment(\.zones, zones)
            .environment(\.remotes, remotes)
        }
    }
}

#Preview {
    ContentView()
}
