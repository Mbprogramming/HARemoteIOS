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
            ForEach(mainModel.commandIds, id: \.self.id) { id in
                VStack {
                    Text(id.id)
                        .font(.subheadline)
                    HStack {
                        Text("Send:")
                            .font(.footnote)
                        Spacer()
                        Text("\(id.timeStamp)")
                            .font(.footnote)
                    }
                    HStack {
                        Text("Received:")
                            .font(.footnote)
                        Spacer()
                        Text("\(String(describing: id.received))")
                            .font(.footnote)
                    }
                    HStack {
                        Text("Finished:")
                            .font(.footnote)
                        Spacer()
                        Text("\(String(describing: id.received))")
                            .font(.footnote)
                    }
                }
                .padding()
                
            }
            Spacer(minLength: 100)
        }
    }
}

#Preview {
    @Previewable @State var mainModel = RemoteMainModel()
    HistoryView(mainModel: $mainModel)
}
