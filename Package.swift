// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GrakerLocal",
    platforms: [.macOS("15.0")],
    products: [.executable(name: "GrakerLocal", targets: ["GrakerLocal"])],
    targets: [
        .target(name: "GrakerCore"),
        .executableTarget(name: "GrakerLocal", dependencies: ["GrakerCore"]),
        .testTarget(name: "GrakerCoreTests", dependencies: ["GrakerCore"])
    ]
)
