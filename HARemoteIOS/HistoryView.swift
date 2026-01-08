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
            ForEach(mainModel.commandIds, id: \.self.id) { id in
                VStack {
                    Text(id.id)
                        .font(.subheadline)
                    Text("\(id.timeStamp)")
                        .font(.footnote)
                    Text("\(String(describing: id.received))")
                        .font(.footnote)
                }
                .padding()
                
            }
        }
    }
}

#Preview {
    @Previewable @State var mainModel = RemoteMainModel()
    HistoryView(mainModel: $mainModel)
}
