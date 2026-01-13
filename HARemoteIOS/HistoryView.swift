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
                    let str1 = id.timeStamp.formatted(date: .numeric, time: .complete)
                    let str2 = id.received == nil ? "-" : id.received!.formatted(date: .numeric, time: .complete)
                    let str3 = id.finished == nil ? "-" : id.finished!.formatted(date: .numeric, time: .complete)
                    Text(id.id)
                        .font(.subheadline)
                    HStack {
                        Text("Send:")
                            .font(.footnote)
                        Spacer()
                        Text("\(str1)")
                            .font(.footnote)
                        
                    }
                    HStack {
                        Text("Received:")
                            .font(.footnote)
                        Spacer()
                        Text("\(str2)")
                            .font(.footnote)
                    }
                    HStack {
                        Text("Finished:")
                            .font(.footnote)
                        Spacer()
                        Text("\(str3)")
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
