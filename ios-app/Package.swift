// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseDataApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FirebaseDataApp",
            targets: ["FirebaseDataApp"]
        ),
    ],
    targets: [
        .target(
            name: "FirebaseDataApp",
            path: "FirebaseDataApp"
        )
    ]
)
