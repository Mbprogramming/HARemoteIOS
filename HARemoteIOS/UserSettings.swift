//
//  UserSettings.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 10.12.25.
//

import SwiftUI
import SwiftData
import Kingfisher

struct UserSettings: View {
    @AppStorage("server") var server: String = "http://192.168.5.106:5000"
    @AppStorage("webserver") var webserver: String = "https://haalexa.azurewebsites.net"
    @AppStorage("username") var username: String = "mbprogramming@googlemail.com"
    @AppStorage("application") var application: String = "HARemoteIOS"
    
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \HueMultiEntry.name, order: .forward) var multiEntries: [HueMultiEntry]
    
    @State var showAlert = false
    @State var cacheSizeResult: Result<UInt, KingfisherError>? = nil

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
                Section("Webserver") {
                    TextField("Web Service URL:", text: $webserver)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                Section("Cache"){
                    Button("Check Cache") {
                                KingfisherManager.shared.cache.calculateDiskStorageSize { result in
                                    cacheSizeResult = result
                                    showAlert = true
                                }
                            }
                            .alert(
                                "Disk Cache",
                                isPresented: $showAlert,
                                presenting: cacheSizeResult,
                                actions: { result in
                                    switch result {
                                    case .success:
                                        Button("Clear") {
                                            KingfisherManager.shared.cache.clearCache()
                                        }
                                        Button("Cancel", role: .cancel) {}
                                    case .failure:
                                        Button("OK") { }
                                    }
                                }, message: { result in
                                    switch result {
                                    case .success(let size):
                                        Text("Size: \(Double(size) / 1024 / 1024) MB")
                                    case .failure(let error):
                                        Text(error.localizedDescription)
                                    }
                                })
                    Button("Clear Cache"){
                        KingfisherManager.shared.cache.clearCache()
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
