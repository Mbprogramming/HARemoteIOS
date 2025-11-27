//
//  SidePaneView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

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
                if zoneContent?.icon != nil {
                    let iconUrl: String = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=" + (zoneContent?.icon ?? "")
                    
                    AsyncImage(url: URL(string: iconUrl))
                        .frame(width: 40, height: 40)
                }
                Text(zoneContent?.description ?? "Unknown zone")
            }
        }
    }
}

struct ItemView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.remotes) var remotes
    
    public var remote: Remote?
    
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    
    var body: some View {
        if remote == nil {
            Text("Unknown remote")
        } else {
            HStack {
                if remote?.icon != nil {
                    let iconUrl: String = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=" + (remote?.icon ?? "")
                    
                    AsyncImage(url: URL(string: iconUrl))
                        .frame(width: 40, height: 40)
                }
                Text(remote?.description ?? "Unknown zone")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if let remote {
                    currentRemote = remote
                    currentRemoteItem = remote.remote
                }
                dismiss()
            }
        }
    }
}

struct SidePaneView: View {
    @Environment(\.remotes) var remotes
    @Environment(\.zones) var zones
    
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]

    // Helper: map a zone’s remoteIds to actual Remote models, skipping missing ones.
    private func remotes(for zone: Zone) -> [Remote] {
        guard let remoteIds = zone.remoteIds, !remoteIds.isEmpty else { return [] }
        let lookup = Dictionary(uniqueKeysWithValues: remotes.map { ($0.id, $0) })
        return remoteIds.compactMap { lookup[$0] }
    }

    var body: some View {
        let visibleZones = zones.filter { $0.isVisible == true }
        
        List {
            ForEach(visibleZones) { zone in
                Section(content: { HeaderView(zone: zone) }, header: {
                    let zoneRemotes = remotes(for: zone)
                    ForEach(zoneRemotes) { remote in
                        ItemView(
                            remote: remote,
                            currentRemote: $currentRemote,
                            currentRemoteItem: $currentRemoteItem
                        )
                    }
                })
            }
        }
    }
}

#Preview {
    @Previewable @State var currentRemote: Remote? = nil
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    
    SidePaneView(
        currentRemote: $currentRemote,
        currentRemoteItem: $currentRemoteItem,
        remoteItemStack: $remoteItemStack
    )
}
