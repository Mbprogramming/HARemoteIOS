// swift-tools-version: 5.9
//
//  Package.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 05.12.25.
//
import PackageDescription

let package = Package(
    name: "signalr-client-app",
    dependencies: [
        .package(url: "https://github.com/dotnet/signalr-client-swift", .upToNextMinor(from: "1.0.0"))
    ],
    targets: [
        .executableTarget(name: "HARemoteIOS", dependencies: [.product(name: "SignalRClient", package: "signalr-client-swift")])
    ]
)