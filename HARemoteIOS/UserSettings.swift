//
//  UserSettings.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 10.12.25.
//

import SwiftUI
import SwiftData

struct UserSettings: View {
    @AppStorage("server") var server: String = "http://192.168.5.106:5000"
    @AppStorage("username") var username: String = "mbprogramming@googlemail.com"
    @AppStorage("application") var application: String = "HARemoteIOS"
    
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \HueMultiEntry.name, order: .forward) var multiEntries: [HueMultiEntry]
    
    var body: some View {
            Form {
                Section("Server"){
                    TextField("Server:", text: $server)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    TextField("User:", text: $username)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    TextField("Application:", text: $application)
                        .disabled(true)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                Section("Cache"){
                    Button("Clear Cache"){
                        return
                    }
                    .buttonStyle(.automatic)
                }
                Section("Hue Predefines") {
                    ForEach(multiEntries, id: \.self.id) { entry in
                        Text(entry.name)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash") {
                                    modelContext.delete(entry)
                                    DispatchQueue.main.async {
                                        try? self.modelContext.save()
                                    }
                                }
                                
                                .tint(.red)
                            }
                    }
                }
            }
            .textFieldStyle(.roundedBorder)
    }
}

#Preview {
    UserSettings()
}
