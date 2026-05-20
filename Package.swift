// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "NovaCibesRunner",
    platforms: [
        // Retains compatibility with your 2013 MacBook Air
        .macOS(.v11)
    ],
    products: [
        .executable(name: "NovaCibesRunner", targets: ["NovaCibesRunner"])
    ],
    dependencies: [
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "20.0.0"),
        .package(url: "https://github.com/twostraws/Sourceful.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "NovaCibesRunner",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "Sourceful", package: "Sourceful")
            ],
            // Isolates source compilation to avoid tracking server.py or build folders
            path: "Sources/NovaCibesRunner",
            swiftSettings: [
                // Compiles with Swift 5 parameters using Swift 6.1 tools.
                // This stops strict concurrency errors from breaking the build.
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
