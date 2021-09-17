//
//  ModificationDate.swift
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

import Foundation
import Glob

/// Provides functions for retrieving a file's modification date.
struct ModificationDate {

    enum Error: Swift.Error {
        case notFound
    }

    /// Finds the modification date for the file at the specified path.
    static func from(path: String) throws -> Date {
        guard let mtime = try FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date else {
            throw Error.notFound
        }
        return mtime
    }

    /// Finds the modification date for the file at the specified URL.
    static func from(url: URL) throws -> Date {
        return try from(path: url.path)
    }

    /// Finds the latest modification date for the files matching the specified glob pattern.
    static func latest(from paths: Glob) throws -> Date {
        let mtimes = try paths.map {
            try from(path: $0)
        }

        guard let mtime = mtimes.max() else {
            throw Error.notFound
        }
        return mtime
    }
}
