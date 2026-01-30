//
//  WebStates.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 30.01.26.
//

import SwiftUI

struct WebStates: View {
    @State private var states: [String] = []
    
    var body: some View {
        List {
            ForEach(states, id:\.self) { state in
                Text(state)
                    .multilineTextAlignment(.leading)
            }
        }
        .task {
            states = (try? await HomeRemoteAPI.shared.getWebStateGroups()) ?? []
        }
        .refreshable {
            Task {
                do {
                    states = (try await HomeRemoteAPI.shared.getWebStateGroups())
                } catch {
                    // handle error if needed
                }
            }
        }
    }
}

#Preview {
    WebStates()
}
