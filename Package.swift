// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DaveKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DaveKit",
            targets: ["DaveKit"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DaveKit",
            dependencies: [.target(name: "libdave")]
        ),

        .target(
            name: "libdave",
            dependencies: [
                .target(name: "mlspp"),
                .target(name: "bytes"),
                .target(name: "tls_syntax"),
            ],
            path: "Sources/CLibdave/libdave/cpp",
            exclude: [
                "test",
                "src/dave/mls/detail/persisted_key_pair_apple.cpp",
                "src/dave/mls/detail/persisted_key_pair_null.cpp",
                "src/dave/mls/detail/persisted_key_pair_win.cpp",
                "src/dave/bindings_wasm.cpp",
                "src/dave/boringssl_cryptor.cpp",
                "src/dave/boringssl_cryptor.h",
            ],
            sources: ["src"],
            publicHeadersPath: "includes",
            cxxSettings: [
                .headerSearchPath("src"),
            ]
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
                .target(name: "json"),
            ],
            path: "Sources/CMLS/mlspp/lib/hpke",
            exclude: ["test"],
            sources: ["src"],
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

        .target(
            name: "json",
            path: "Sources/CJson/json/single_include",
            publicHeadersPath: ".",
        ),

        .testTarget(
            name: "DaveKitTests",
            dependencies: ["DaveKit"]
        ),
    ]
)
