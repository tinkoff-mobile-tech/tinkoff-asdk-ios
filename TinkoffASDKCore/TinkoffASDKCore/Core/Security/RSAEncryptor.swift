//
//
//  RSAEncryptor.swift
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

import Foundation

protocol IRSAEncryptor {
    func createPublicSecKey(publicKey: String) -> SecKey?
    func encrypt(string: String, publicKey: SecKey) -> String?
}

final class RSAEncryptor: IRSAEncryptor {
    func createPublicSecKey(publicKey: String) -> SecKey? {
        guard let data = Data(base64Encoded: publicKey) else {
            return nil
        }

        var attributes: CFDictionary {
            return [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits: 2048,
                kSecReturnPersistentRef: kCFBooleanTrue!,
            ] as CFDictionary
        }

        var error: Unmanaged<CFError>?
        return SecKeyCreateWithData(data as CFData, attributes, &error)
    }

    func encrypt(string: String, publicKey: SecKey) -> String? {
        let buffer = [UInt8](string.utf8)

        var keySize = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)

        guard SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) == errSecSuccess else {
            return nil
        }

        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
    }
}

private extension RSAEncryptor {
    func stripBeginEndMarks(string: String) -> String {
        return string
            .replacingOccurrences(of: "-----BEGIN RSA PUBLIC KEY-----\n", with: "")
            .replacingOccurrences(of: "\n-----END RSA PUBLIC KEY-----", with: "")
    }
}
