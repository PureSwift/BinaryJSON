import PackageDescription

let package = Package(
    name: "BinaryJSON",
    dependencies: [
        .Package(url: "https://github.com/PureSwift/CBSON.git", majorVersion: 1),
        .Package(url: "https://github.com/PureSwift/SwiftFoundation.git", majorVersion: 1)
    ],
    targets: [
        Target(
            name: "UnitTests",
            dependencies: [.Target(name: "BinaryJSON")]),
        Target(
            name: "BinaryJSON")
    ]
)