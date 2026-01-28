//
//  HistoryView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct HistoryView: View {
    @Binding var mainModel: RemoteMainModel
    
    var body: some View {
        List {
            Spacer(minLength: 100)
            ForEach(mainModel.commandIds, id: \.id) { id in
                VStack {
                    HStack {
                        Text(id.id)
                            .font(.subheadline)
                        Spacer()
                    }
                    HStack {
                        Text("Send:")
                            .font(.footnote)
                        Spacer()
                        Text("\(id.sendStr)")
                            .font(.footnote)
                        
                    }
                    HStack {
                        Text("Received:")
                            .font(.footnote)
                        Spacer()
                        Text("\(id.receivedStr)")
                            .font(.footnote)
                    }
                    HStack {
                        Text("Finished:")
                            .font(.footnote)
                        Spacer()
                        Text("\(id.finishedStr)")
                            .font(.footnote)
                    }
                }
                .listRowBackground(Color.clear)
                .padding()
            }
            Spacer(minLength: 100)
        }
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
        .listStyle(.insetGrouped)
    }
}

#Preview {
    @Previewable @State var mainModel = RemoteMainModel()
    HistoryView(mainModel: $mainModel)
}
