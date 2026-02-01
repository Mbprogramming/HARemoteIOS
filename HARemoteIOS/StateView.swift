//
//  StateView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct StateItemView: View {
    var state: HAState
    
    var body: some View {
        VStack {
            HStack {
                    if state.showImage, let icon = state.icon {
                        AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: icon)
                            .frame(width: 40, height: 40)
                    }
                Spacer()
                VStack {
                    HStack {
                        Spacer()
                        Text("\(state.device ?? "") \(state.id ?? "")")
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    HStack{
                        Spacer()
                        Text(state.convertedValue ?? "")
                            .bold()
                    }
                }
            }
            .padding()
            HStack {
                Spacer()
                if let ls = state.lastChangeDate {
                    Text(ls.formatted())
                        .font(.footnote)
                }
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(state.calculatedColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
        )
    }
}

struct StateView: View {
    @Binding var remoteStates: [HAState]
    @Binding var currentRemote: Remote?
    @Environment(\.mainWindowSize) var mainWindowSize
    
    @State private var currentFilter: Int = 0
    
    var body: some View {
        VStack {
            List {
                let sortedStates = currentFilter == 0 ? remoteStates.sorted { $0.lastChangeDate ?? Date.now > $1.lastChangeDate ?? Date.now } : remoteStates.sorted { $0.device ?? "" < $1.device ?? "" }
                if sortedStates.count > 0 {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 150)
                        .listRowBackground(Color.clear)
                }
                ForEach(sortedStates){state in
                    StateItemView(state: state)
                }
                if sortedStates.count > 0 {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 150)
                        .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .listRowSeparator(.hidden)
            .refreshable {
                do {
                    let entries = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                    remoteStates = entries
                } catch {
                    NSLog("Failed refreshing remote states: \(error)")
                }
            }
            .ignoresSafeArea()
        }
        .safeAreaInset(edge: .top) {
            Picker("Filter", selection: $currentFilter) {
                Text("Date ").tag(0)
                Text("Device").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    @Previewable @State var remoteStates: [HAState] = []
    @Previewable @State var currentRemote: Remote? = nil
    
    StateView(remoteStates: $remoteStates, currentRemote: $currentRemote)
}
