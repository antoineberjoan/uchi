// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GrakerLocal",
    platforms: [.macOS("15.0"), .iOS("18.0")],
    products: [
        .executable(name: "GrakerLocal", targets: ["GrakerMac"]),
        .executable(name: "GrakerIOS", targets: ["GrakerIOS"]),
        .library(name: "GrakerUI", targets: ["GrakerUI"]),
        .library(name: "GrakerDesign", targets: ["GrakerDesign"]),
        .library(name: "GrakerKeyboard", targets: ["GrakerKeyboard"]),
    ],
    targets: [
        .target(name: "GrakerCore"),
        .target(name: "GrakerDesign"),
        .target(name: "GrakerPlatform", dependencies: ["GrakerCore"]),
        .target(name: "GrakerUI", dependencies: ["GrakerCore", "GrakerDesign", "GrakerPlatform"]),
        .target(name: "GrakerKeyboard", dependencies: ["GrakerCore", "GrakerPlatform", "GrakerUI"]),
        .executableTarget(name: "GrakerMac", dependencies: ["GrakerCore", "GrakerUI", "GrakerDesign"]),
        .executableTarget(name: "GrakerIOS", dependencies: ["GrakerCore", "GrakerUI", "GrakerDesign"]),
        .testTarget(name: "GrakerCoreTests", dependencies: ["GrakerCore"]),
        .testTarget(name: "GrakerPlatformTests", dependencies: ["GrakerPlatform", "GrakerCore"])
    ]
)
