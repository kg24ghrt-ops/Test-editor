	<// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "NovaCibesRunner",
    platforms: [
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
            path: "."
        )
    ]
)
