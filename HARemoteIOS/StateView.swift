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
                if state.showImage {
                    AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: state.icon!)
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
            Picker("Filter", selection: $currentFilter) {
                Text("Date ").tag(0)
                Text("Device").tag(1)
            }
            .pickerStyle(.segmented)
            List {
                let height = mainWindowSize.height * 0.2
                let sortedStates = currentFilter == 0 ? remoteStates.sorted { $0.lastChangeDate ?? Date.now > $1.lastChangeDate ?? Date.now } : remoteStates.sorted { $0.device ?? "" < $1.device ?? "" }
                ForEach(sortedStates){state in
                    StateItemView(state: state)
                }
                Spacer(minLength: height)
            }
            .scrollContentBackground(.hidden)
            .listRowSeparator(.hidden)
            .refreshable {
                Task {
                    do {
                        let entries = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                        await MainActor.run {
                            remoteStates = entries
                        }
                    } catch {
                        // handle error if needed
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var remoteStates: [HAState] = []
    @Previewable @State var currentRemote: Remote? = nil
    
    StateView(remoteStates: $remoteStates, currentRemote: $currentRemote)
}
