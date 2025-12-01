//
//  SidePaneView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct HeaderView: View {
    private var zoneContent: Zone?
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    init(zone: Zone?) {
        zoneContent = zone
    }
    
    var body: some View {
        if zoneContent == nil {
            Text("Unknown zone")
        } else {
            HStack {
                if let iconId = zoneContent?.icon {
                    if colorScheme == .light {
                        let iconUrl = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=\(iconId)"
                        AsyncImage(url: URL(string: iconUrl))
                            .frame(width: 40, height: 40)
                    } else {
                        let iconUrl = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=\(iconId)"
                        AsyncImage(url: URL(string: iconUrl))
                            .frame(width: 40, height: 40)
                    }
                }
                Text(zoneContent?.description ?? "Unknown zone")
            }
        }
    }
}

struct ItemView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    public var remote: Remote
    
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    
    var body: some View {
        HStack {
            if let iconId = remote.icon {
                if colorScheme == .light {
                    let iconUrl = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=\(iconId)"
                    AsyncImage(url: URL(string: iconUrl))
                        .frame(width: 40, height: 40)
                } else {
                    let iconUrl = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=\(iconId)"
                    AsyncImage(url: URL(string: iconUrl))
                        .frame(width: 40, height: 40)
                }
            }
            Text(remote.description)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            currentRemote = remote
            currentRemoteItem = remote.remote
            remoteItemStack.removeAll()
            dismiss()
        }
    }
}

struct SidePaneView: View {
    @Environment(\.remotes) var remotes
    @Environment(\.zones) var zones
    
    @Binding var currentRemote: Remote?
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]

    var body: some View {
        // Precompute visible zones to keep the builder simple
        let visibleZones: [Zone] = zones.filter { $0.isVisible == true }
        
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
                            remoteItemStack: $remoteItemStack
                        )
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
    
    SidePaneView(
        currentRemote: $currentRemote,
        currentRemoteItem: $currentRemoteItem,
        remoteItemStack: $remoteItemStack
    )
}

