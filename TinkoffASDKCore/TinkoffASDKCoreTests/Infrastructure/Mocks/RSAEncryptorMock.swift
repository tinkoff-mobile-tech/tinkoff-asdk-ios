//
//  RSAEncryptorMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class RSAEncryptorMock: IRSAEncryptor {

    // MARK: - createPublicSecKey

    typealias CreatePublicSecKeyArguments = String

    var createPublicSecKeyCallsCount = 0
    var createPublicSecKeyReceivedArguments: CreatePublicSecKeyArguments?
    var createPublicSecKeyReceivedInvocations: [CreatePublicSecKeyArguments?] = []
    var createPublicSecKeyReturnValue: SecKey?

    func createPublicSecKey(publicKey: String) -> SecKey? {
        createPublicSecKeyCallsCount += 1
        let arguments = publicKey
        createPublicSecKeyReceivedArguments = arguments
        createPublicSecKeyReceivedInvocations.append(arguments)
        return createPublicSecKeyReturnValue
    }

    // MARK: - encrypt

    typealias EncryptArguments = (string: String, publicKey: SecKey)

    var encryptCallsCount = 0
    var encryptReceivedArguments: EncryptArguments?
    var encryptReceivedInvocations: [EncryptArguments?] = []
    var encryptReturnValue: String?

    func encrypt(string: String, publicKey: SecKey) -> String? {
        encryptCallsCount += 1
        let arguments = (string, publicKey)
        encryptReceivedArguments = arguments
        encryptReceivedInvocations.append(arguments)
        return encryptReturnValue
    }
}

// MARK: - Resets

extension RSAEncryptorMock {
    func fullReset() {
        createPublicSecKeyCallsCount = 0
        createPublicSecKeyReceivedArguments = nil
        createPublicSecKeyReceivedInvocations = []

        encryptCallsCount = 0
        encryptReceivedArguments = nil
        encryptReceivedInvocations = []
    }
}
