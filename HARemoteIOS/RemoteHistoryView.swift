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
    @Binding var remoteStates: [HAState]
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var isVisible: Bool
    @Binding var orientation: UIDeviceOrientation
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
        
    var body: some View {
        HStack {
            RemoteHistoryButton(remote: remote1, currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $isVisible)
                .frame(width: 100, height: 100)
                .padding()
            if let remote2 {
                RemoteHistoryButton(remote: remote2!, currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $isVisible)
                    .frame(width: 100, height: 100)
                    .padding()
            }
            if orientation == .landscapeLeft || orientation == .landscapeRight {
                if let remote3 {
                    RemoteHistoryButton(remote: remote3!, currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $isVisible)
                        .frame(width: 100, height: 100)
                        .padding()
                }
            }
        }
    }

struct RemoteHistoryButton: View {
    var remote: Remote
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteStates: [HAState]
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var isVisible: Bool

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        Button(action: performAction) {
            VStack {
                if remote.icon != nil {
                    AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: remote.icon!)
                        .frame(width: 40, height: 40)
                }
                Text(remote.description)
                    .truncationMode(.middle)
                    .allowsTightening(true)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .font(.title)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(colorScheme == .dark ? .white : .black)
    }

    private func performAction() {
        remoteStates = []
        currentRemote = remote
        currentRemoteItem = remote.remote
        remoteItemStack.removeAll()
        Task {
            do {
                let entries = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                remoteStates = entries
            } catch {
                NSLog("Failed to load remote states: \(error)")
            }
        }
        isVisible = false
    }
}
}

struct RemoteHistoryView: View {
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteStates: [HAState]
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
    @Previewable @State var remoteStates: [HAState] = []
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var isVisible: Bool = true
    @Previewable @State var orientation: UIDeviceOrientation = UIDeviceOrientation.portrait
    
    var remotes : [Remote] = []
    
    RemoteHistoryView(currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $isVisible, orientation: $orientation, remotes: remotes)
}
