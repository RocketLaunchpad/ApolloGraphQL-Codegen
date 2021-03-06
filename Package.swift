// swift-tools-version:5.3
//
//  Package.swift
//  ApolloGraphQL-Codegen
//
//  Copyright (c) 2021 Rocket Insights, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import PackageDescription

let package = Package(
    name: "codegen",
    platforms: [.macOS("10.14")],
    products: [
        .executable(name: "codegen",
                    targets: ["codegen"]),
    ],
    dependencies: [
        .package(name: "Apollo",
                 url: "https://github.com/apollographql/apollo-ios.git",
                 .upToNextMinor(from: "0.51.1")),
        .package(url: "https://github.com/apple/swift-argument-parser",
                 .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Bouke/Glob",
                 from: "1.0.5"),
    ],
    targets: [
        .target(name: "codegen",
                dependencies: [
                    .product(name: "ApolloCodegenLib", package: "Apollo"),
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    .product(name: "Glob", package: "Glob"),
                ]),
    ]
)
