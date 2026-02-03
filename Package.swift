// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DaveKit",
    products: [
        .library(
            name: "DaveKit",
            targets: ["DaveKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.9.0")
    ],
    targets: [
        .target(
            name: "DaveKit",
            dependencies: [
                .target(name: "CLibdave"),
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),

        .target(
            name: "CLibdave",
            dependencies: [
                .target(name: "mlspp"),
                .target(name: "bytes"),
                .target(name: "tls_syntax"),
            ],
            exclude: [
                "libdave/cpp/test",
                "libdave/cpp/src/mls/detail/persisted_key_pair_apple.cpp",
                "libdave/cpp/src/mls/detail/persisted_key_pair_null.cpp",
                "libdave/cpp/src/mls/detail/persisted_key_pair_win.cpp",
                "libdave/cpp/src/bindings_wasm.cpp",
                "libdave/cpp/src/boringssl_cryptor.cpp",
                "libdave/cpp/src/boringssl_cryptor.h",
            ],
            sources: ["libdave/cpp/src"],
            cxxSettings: [
                .headerSearchPath("libdave/cpp/includes"),
                .headerSearchPath("libdave/cpp/src"),
            ],
        ),

        .target(
            name: "mlspp",
            dependencies: [
                .target(name: "hpke"),
                .target(name: "bytes"),
                .target(name: "tls_syntax"),
            ],
            path: "Sources/CMLS/mlspp",
            exclude: ["test"],
            sources: ["src"],
            cxxSettings: [
                .define("WITH_PQ")
            ],
        ),

        .target(
            name: "mlspp_namespace",
            path: "Sources/CMLS/namespace",
            publicHeadersPath: ".",
        ),

        .target(
            name: "hpke",
            dependencies: [
                .target(name: "mlspp_namespace"),
                .target(name: "bytes"),
                .target(name: "tls_syntax"),
                .target(name: "CJson"),
            ],
            path: "Sources/CMLS/mlspp/lib/hpke",
            exclude: ["test"],
            sources: ["src"],
            cxxSettings: [
                .define("WITH_OPENSSL3"),
            ],
        ),

        .target(
            name: "bytes",
            dependencies: [
                .target(name: "mlspp_namespace"),
                .target(name: "tls_syntax"),
            ],
            path: "Sources/CMLS/mlspp/lib/bytes",
            exclude: ["test"],
            sources: ["src"],
        ),

        .target(
            name: "tls_syntax",
            dependencies: [.target(name: "mlspp_namespace")],
            path: "Sources/CMLS/mlspp/lib/tls_syntax",
            exclude: ["test"],
            sources: ["src"],
        ),

        .target(name: "CJson"),

        .testTarget(
            name: "DaveKitTests",
            dependencies: ["DaveKit"],
        ),
    ],
    cxxLanguageStandard: .cxx17,
)
