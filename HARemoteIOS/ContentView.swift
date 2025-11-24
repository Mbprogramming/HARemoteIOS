//
//  ContentView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 21.11.25.
//

import SwiftUI

struct ContentView: View {
    @State private var navigateToSettings: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showSmallPopup: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                NavigationStack {
                    TabView {
                        NavigationView {
                            RemoteView()
                        }
                        .tabItem {
                            Label("Remote", systemImage: "av.remote")
                        }
                        .background(
                            NavigationLink("", destination: SidePaneView(), isActive: $navigateToHome)
                                .hidden()
                        )
                        NavigationView {
                            StateView()
                        }
                        .tabItem {
                            Label("States", systemImage: "flag")
                        }
                        NavigationView {
                            HistoryView()
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
                            // On iOS 17+, keep popover style in compact environments:
                            // .presentationCompactAdaptation(.popover)
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Home", systemImage: "house") {
                                navigateToHome = true
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            Text("Remote")
                                .font(.headline)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
