// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GrakerLocal",
    platforms: [.macOS("15.0"), .iOS("18.0")],
    products: [
        .executable(name: "GrakerLocal", targets: ["GrakerMac"]),
        .executable(name: "GrakerIOS", targets: ["GrakerIOS"])
    ],
    targets: [
        .target(name: "GrakerCore"),
        .target(name: "GrakerDesign"),
        .target(name: "GrakerPlatform", dependencies: ["GrakerCore"]),
        .target(name: "GrakerUI", dependencies: ["GrakerCore", "GrakerDesign", "GrakerPlatform"]),
        .executableTarget(name: "GrakerMac", dependencies: ["GrakerCore", "GrakerUI", "GrakerDesign"]),
        .executableTarget(name: "GrakerIOS", dependencies: ["GrakerCore", "GrakerUI", "GrakerDesign"]),
        .testTarget(name: "GrakerCoreTests", dependencies: ["GrakerCore"]),
        .testTarget(name: "GrakerPlatformTests", dependencies: ["GrakerPlatform", "GrakerCore"])
    ]
)
