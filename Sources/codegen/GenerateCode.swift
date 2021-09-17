//
//  GenerateCode.swift
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
import Glob

/// Generates code based on a schema and a set of user-provided GraphQL queries and mutations.
///
/// This command uses the modification date of the input files (the `schemaFile` and all of the files matching the `includes` glob pattern) and compares it to the modification date of the `outputFile`. If the `outputFile` was modified after all of the input files, no code generation is performed. This speeds up subsequent builds of the project that includes the generated code, only recompiling it when the inputs have actually changed. This check can be overridden by the `force` flag.
struct GenerateCode: ParsableCommand {

    enum GenerateCodeError: Error {
        case badModificationTime
    }

    @Option(name: .shortAndLong, help: "The Apollo CLI directory. If the CLI has not yet been downloaded, it will be downloaded and stored here.")
    var cliDir: Argument.Directory

    @Flag(name: .shortAndLong, help: "Print debug output.")
    var debug: Bool = false

    @Option(name: .shortAndLong, help: "Force the build to occur, ignoring modification times of input and output files.")
    var force: Bool = false

    @ArgumentParser.Argument(help: "Glob pattern specifying user-provided GraphQL queries and mutations to be included.")
    var includes: String

    @Option(name: .shortAndLong, help: "Generated code output filename.")
    var outputFile: Argument.File

    @Option(name: .shortAndLong, help: "Schema filename.")
    var schemaFile: Argument.File

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
        debug("GenerateCode arguments:")
        debug("  force: \(force)")
        debug("  includes: \(includes)")
        debug("  outpoutFile: \(outputFile.url)")
        debug("  schemaFile: \(schemaFile.url)")

        guard shouldBuild else {
            return
        }

        let options = ApolloCodegenOptions(includes: includes,
                                           outputFormat: .singleFile(atFileURL: outputFile.url),
                                           customScalarFormat: .passthrough,
                                           urlToSchemaFile: schemaFile.url)
        let pwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)

        try ApolloCodegen.run(from: pwd, with: cliDir.url, options: options)
    }

    /// Returns `true` if either the modification dates or the `force` flag indicates that a build should occur.
    private var shouldBuild: Bool {
        if force {
            debug("Should build? YES (Forced via command-line)")
            return true
        }

        do {
            let includesLastChangedAt = try ModificationDate.latest(from: Glob(pattern: includes))
            debug("Includes last changed at \(includesLastChangedAt)")

            let schemaLastChangedAt = try ModificationDate.from(url: schemaFile.url)
            debug("Schema last changed at \(schemaLastChangedAt)")

            let inputLastChangedAt = max(includesLastChangedAt, schemaLastChangedAt)
            debug("Input last changed at \(inputLastChangedAt)")

            let outputLastChangedAt = try ModificationDate.from(url: outputFile.url)
            debug("Output last changed at \(outputLastChangedAt)")

            if inputLastChangedAt >= outputLastChangedAt {
                debug("Should build? YES (Input changed more recently than output)")
                return true
            }
            else {
                debug("Should build? NO (Output changed more recently than input)")
                return false
            }
        }
        catch {
            debug("Should build? YES (Error checking mtimes)")
            return true
        }
    }
}
