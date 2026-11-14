// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Imi",
    platforms: [.macOS("15.0"), .iOS("18.0")],
    products: [
        .executable(name: "Imi", targets: ["ImiMac"]),
        .executable(name: "ImiIOS", targets: ["ImiIOS"]),
        .library(name: "ImiUI", targets: ["ImiUI"]),
        .library(name: "ImiDesign", targets: ["ImiDesign"]),
        .library(name: "ImiKeyboard", targets: ["ImiKeyboard"]),
    ],
    targets: [
        .target(name: "ImiCore"),
        .target(name: "ImiDesign"),
        .target(name: "ImiPlatform", dependencies: ["ImiCore"]),
        .target(name: "ImiUI", dependencies: ["ImiCore", "ImiDesign", "ImiPlatform"]),
        .target(name: "ImiKeyboard", dependencies: ["ImiCore", "ImiPlatform", "ImiUI"]),
        .executableTarget(name: "ImiMac", dependencies: ["ImiCore", "ImiUI", "ImiDesign"]),
        .executableTarget(name: "ImiIOS", dependencies: ["ImiCore", "ImiUI", "ImiDesign"]),
        .testTarget(name: "ImiCoreTests", dependencies: ["ImiCore"]),
        .testTarget(name: "ImiPlatformTests", dependencies: ["ImiPlatform", "ImiCore"])
    ]
)
