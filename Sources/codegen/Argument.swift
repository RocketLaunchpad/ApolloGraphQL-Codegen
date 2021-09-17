//
//  Argument.swift
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

import ArgumentParser
import Foundation

/// Provides various command-line argument types.
struct Argument {

    /// A command-line argument that references a directory.
    struct Directory: ExpressibleByArgument {
        var url: Foundation.URL

        init?(argument: String) {
            self.url = Foundation.URL(fileURLWithPath: argument, isDirectory: true)
        }
    }

    /// A command-line argument that references a file.
    struct File: ExpressibleByArgument {
        var url: Foundation.URL

        init?(argument: String) {
            self.url = Foundation.URL(fileURLWithPath: argument, isDirectory: false)
        }
    }

    /// A command-line argument that references a URL.
    struct URL: ExpressibleByArgument {
        var url: Foundation.URL

        init?(argument: String) {
            guard let url = Foundation.URL(string: argument) else {
                return nil
            }
            self.url = url
        }
    }
}
