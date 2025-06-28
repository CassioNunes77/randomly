// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Aleatoriamente",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Aleatoriamente",
            targets: ["Aleatoriamente"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "Aleatoriamente",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS")
            ]),
        .testTarget(
            name: "AleatoriamenteTests",
            dependencies: ["Aleatoriamente"]),
    ]
) 