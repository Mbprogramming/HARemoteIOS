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
    private var remoteContent: Remote?
    
    init(remote: Remote?) {
        remoteContent = remote
    }
    
    var body: some View {
        if remoteContent == nil {
            Text("Unknown remote")
        } else {
            HStack {
                if remoteContent?.icon != nil {
                    let iconUrl: String = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=" + (remoteContent?.icon ?? "")
                    
                    AsyncImage(url: URL(string: iconUrl))
                        .frame(width: 40, height: 40)
                }
                Text(remoteContent?.description ?? "Unknown zone")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .gesture(TapGesture(count: 1).onEnded({ _ in
                if remoteContent != nil {
                    HomeRemoteAPI.shared.currentRemote = remoteContent
                }
                dismiss()
            }))
        }
    }
}

struct SidePaneView: View {
    @State public var zoneViewModel = ZoneViewModel()
    
    var body: some View {
        List {
            ForEach(zoneViewModel.zones) { zone in
                if zone.isVisible ?? false {
                    Section(header: HeaderView(zone: zone)) {
                        if let remoteIds = zone.remoteIds {
                            ForEach(remoteIds, id: \.self){ remote in
                                let remote = zoneViewModel.remotes.first(where: { $0.id == remote })
                                if remote != nil {
                                    ItemView(remote: remote)
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            await zoneViewModel.loadRemotes()
            await zoneViewModel.loadZones()
        }
    }
}


#Preview {
    SidePaneView()
}
