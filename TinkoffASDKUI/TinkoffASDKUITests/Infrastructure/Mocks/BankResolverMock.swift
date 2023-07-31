//
//  MockBankResolver.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation

final class BankResolverMock: IBankResolver {

    // MARK: - resolve

    typealias ResolveArguments = String

    var resolveCallsCount = 0
    var resolveReceivedArguments: ResolveArguments?
    var resolveReceivedInvocations: [ResolveArguments?] = []
    var resolveReturnValue: BankResult = .incorrectInput(error: .noValue)

    func resolve(cardNumber: String?) -> BankResult {
        resolveCallsCount += 1
        let arguments = cardNumber
        resolveReceivedArguments = arguments
        resolveReceivedInvocations.append(arguments)
        return resolveReturnValue
    }
}

// MARK: - Resets

extension BankResolverMock {
    func fullReset() {
        resolveCallsCount = 0
        resolveReceivedArguments = nil
        resolveReceivedInvocations = []
    }
}
