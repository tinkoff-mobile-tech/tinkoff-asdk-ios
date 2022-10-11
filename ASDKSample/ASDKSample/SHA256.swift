//
//
//  SHA256.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CommonCrypto
import Foundation

enum SHA256 {
    private enum Error: Swift.Error {
        case failedToHash(input: String)
    }

    static func hash(from string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw Error.failedToHash(input: string)
        }

        return hexString(from: digest(input: data as NSData))
    }

    private static func hexString(from data: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: data.length)
        data.getBytes(&bytes, length: data.length)

        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private static func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
}
