//
//  Utils.swift
//  TinkoffASDKCore
//
//  Copyright (c) 2020 Tinkoff Bank
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
import Security
import class UIKit.UIDevice

struct RSAEncryption {
    static func secKey(string: String?) -> SecKey? {
        guard let publicKey = string else { return nil }

        let keyString = publicKey.replacingOccurrences(of: "-----BEGIN RSA PUBLIC KEY-----\n", with: "").replacingOccurrences(of: "\n-----END RSA PUBLIC KEY-----", with: "")

        guard let data = Data(base64Encoded: keyString) else { return nil }

        var attributes: CFDictionary {
            return [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass: kSecAttrKeyClassPublic,
                    kSecAttrKeySizeInBits: 2048,
                    kSecReturnPersistentRef: kCFBooleanTrue!] as CFDictionary
        }

        var error: Unmanaged<CFError>?

        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            print(error.debugDescription)
            return nil
        }

        return secKey
    }

    static func encrypt(string: String?, publicKey: String?) -> String? {
        guard let secKey = secKey(string: publicKey) else { return nil }

        return encrypt(string: string, publicKey: secKey)
    }

    static func encrypt(string: String?, publicKey: SecKey) -> String? {
        guard let value = string else { return nil }

        let buffer = [UInt8](value.utf8)

        var keySize = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)

        guard SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) == errSecSuccess else { return nil }

        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
    }
}

struct DeviceInfo {
    var model: String // = UIDevice.current.localizedModel
    var systemName: String // = UIDevice.current.systemName
    var systemVersion: String // = UIDevice.current.systemVersion
}

// MARK: URL Session Conformance

public protocol Cancellable: AnyObject {
    func cancel()
}

public final class EmptyCancellable: Cancellable {
    public init() {}

    public func cancel() {}
}

extension URLSessionTask: Cancellable {}

// MARK: JSON Conformance

public typealias JSONValue = Any

public typealias JSONObject = [String: JSONValue]

final class JSONSerializationFormat {
    public class func serialize(value: [String: JSONObject]) throws -> Data {
        return try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
    }

    public class func deserialize(data: Data) throws -> JSONValue {
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
}

public extension Encodable {
    func encode2JSONObject(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate) throws -> JSONObject {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy

        let data = try encoder.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else { throw NSError() }

        return dictionary
    }
}

extension String {
    func sha256() -> String {
        if let stringData = data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }

        return ""
    }

    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)

        return NSData(bytes: hash, length: digestLength)
    }

    private func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }

        return hexString
    }
}

public enum IPAddressProvider {
    public static func getIPAddresses() -> [String] {
        var addresses: [String] = []

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }

        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee

            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }

        freeifaddrs(ifaddr)

        return addresses
    }

    static func my() -> String? {
        let addresses = getIPAddresses()
        let ipAddressFactory = IPAddressFactory()
        
        return addresses.compactMap { ipAddressFactory.ipAddress(with: $0) }.first?.fullStringValue
    }
}

extension Optional {
    func orThrow<E: Error>(_ error: @autoclosure () -> E) throws -> Wrapped {
        guard let self = self else {
            throw error()
        }

        return self
    }
}

extension UIDevice {
     var deviceModel: String {
         var systemInfo = utsname()
         uname(&systemInfo)
         let machineMirror = Mirror(reflecting: systemInfo.machine)
         let identifier = machineMirror.children.reduce("") { identifier, element in
             guard let value = element.value as? Int8, value != 0 else { return identifier }
             return identifier + String(UnicodeScalar(UInt8(value)))
         }
         return identifier
     }
 }
