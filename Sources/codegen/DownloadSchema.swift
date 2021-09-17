//
//  DownloadSchema.swift
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

import ApolloCodegenLib
import ArgumentParser
import Foundation

/// Downloads a GraphQL schema.
struct DownloadSchema: ParsableCommand {

    enum Format: String, ExpressibleByArgument {
        case json
        case sdl

        init?(argument: String) {
            self.init(rawValue: argument)
        }

        var schemaFileType: ApolloSchemaOptions.SchemaFileType {
            switch self {
            case .json: return .json
            case .sdl: return .schemaDefinitionLanguage
            }
        }
    }

    @Option(name: .shortAndLong, help: "The Apollo CLI directory. If the CLI has not yet been downloaded, it will be downloaded and stored here.")
    var cliDir: Argument.Directory

    @Flag(name: .shortAndLong, help: "Print debug output.")
    var debug: Bool = false

    @Option(name: .shortAndLong, help: "The endpoint from which the schema is to be downloaded.")
    var endpoint: Argument.URL

    @Option(name: .shortAndLong, help: "The output format. (Default: json)")
    var formats: [Format] = [.json]

    @Option(name: .shortAndLong, help: "The directory to which the schema is to be written.")
    var outputDir: Argument.Directory

    private func debug(_ output: String) {
        guard debug else {
            return
        }
        print(output)
    }

    func run() {
        do {
            try _run()
        }
        catch {
            Foundation.exit(1)
        }
    }

    private func _run() throws {
        debug("DownloadSchema arguments:")
        debug("  cliDir: \(cliDir.url)")
        debug("  endpoint: \(endpoint.url)")
        debug("  outputDir: \(outputDir.url)")

        // Use Apollo to download the specified schema and save it using the specified format(s).
        for format in formats {
            let options = ApolloSchemaOptions(schemaFileType: format.schemaFileType,
                                              endpointURL: endpoint.url,
                                              outputFolderURL: outputDir.url)

            try ApolloSchemaDownloader.run(with: cliDir.url, options: options)
        }
    }
}
