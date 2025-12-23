//
//  UserSettings.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 10.12.25.
//

import SwiftUI

struct UserSettings: View {
    @AppStorage("server") var server: String = "http://192.168.5.106:5000"
    @AppStorage("username") var username: String = "mbprogramming@googlemail.com"
    @AppStorage("application") var application: String = "HARemoteIOS"
    
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
            }
            .textFieldStyle(.roundedBorder)
    }
}

#Preview {
    UserSettings()
}
