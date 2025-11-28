//
//  HistoryView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct HistoryView: View {
    @Binding var commandIds: [String]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(commandIds, id: \.self) { id in
                    Text(id)
                        .padding()
                        .font(.title3)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var commandIds: [String] = []
    HistoryView(commandIds: $commandIds)
}
