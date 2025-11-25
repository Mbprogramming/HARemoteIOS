//
//  SidePaneView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct HeaderView: View {
    private var textContent: String = "Unknown"
    
    init(text: String) {
        textContent = text
    }
    
    var body: some View {
        HStack {
            Text(textContent)
        }
    }
}

struct ItemView: View {
    private var textContent: String = "Unknown"
    
    init(text: String) {
        textContent = text
    }
    
    var body: some View {
        HStack {
            Text(textContent)
        }
    }
}

struct SidePaneView: View {
    @State public var zoneViewModel = ZoneViewModel()
    
    var body: some View {
        List {
            ForEach(zoneViewModel.zones) { zone in
                if zone.isVisible ?? false {
                    Section(header: HeaderView(text: zone.description)) {
                        if let remoteIds = zone.remoteIds {
                            ForEach(remoteIds, id: \.self){ remote in
                                let remoteDesc = zoneViewModel.remotes.first(where: { $0.id == remote })?.description
                                if remoteDesc != nil {
                                    ItemView(text: remoteDesc ?? "Unknown")
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
