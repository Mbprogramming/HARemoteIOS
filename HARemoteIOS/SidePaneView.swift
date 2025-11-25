//
//  SidePaneView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct SidePaneView: View {
    @StateObject public var zoneViewModel = ZoneViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(zoneViewModel.zones) { zone in
                    if (zone.isVisible ?? false) {
                        VStack {
                            Text(zone.description)
                                .font(.headline)
                                .padding()
                            if let remoteIds = zone.remoteIds {
                                LazyVStack(alignment: .leading, spacing: 8) {
                                    ForEach(remoteIds, id: \.self) { remote in
                                        let remoteDesc = zoneViewModel.remotes.first(where: { $0.id == remote })?.description
                                        if remoteDesc != nil {
                                            Text(remoteDesc ?? "Unknown")
                                                .padding(.all)
                                        }
                                    }
                                }
                            }
                        }
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.all)
                    }
                }
            }
            .padding(.horizontal)
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
