//
//  PaymentSystemResolverMock.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation

final class PaymentSystemResolverMock: IPaymentSystemResolver {

    // MARK: - resolve

    typealias ResolveArguments = String

    var resolveCallsCount = 0
    var resolveReceivedArguments: ResolveArguments?
    var resolveReceivedInvocations: [ResolveArguments?] = []
    var resolveReturnValue: PaymentSystemDecision = .unrecognized

    func resolve(by inputPAN: String?) -> PaymentSystemDecision {
        resolveCallsCount += 1
        let arguments = inputPAN
        resolveReceivedArguments = arguments
        resolveReceivedInvocations.append(arguments)
        return resolveReturnValue
    }
}

// MARK: - Resets

extension PaymentSystemResolverMock {
    func fullReset() {
        resolveCallsCount = 0
        resolveReceivedArguments = nil
        resolveReceivedInvocations = []
    }
}
