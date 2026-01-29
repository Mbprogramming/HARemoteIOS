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
            if mainModel.commandIds.count > 0 {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 150)
            }
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
            if mainModel.commandIds.count > 0 {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 150)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .ignoresSafeArea()
    }
}

#Preview {
    @Previewable @State var mainModel = RemoteMainModel()
    HistoryView(mainModel: $mainModel)
}
