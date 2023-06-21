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

    var resolveCallsCount = 0
    var resolveReceivedArguments: String?
    var resolveReceivedInvocations: [String?] = []
    var resolveReturnValue: PaymentSystemDecision = .unrecognized

    func resolve(by inputPAN: String?) -> PaymentSystemDecision {
        resolveCallsCount += 1
        let arguments = inputPAN
        resolveReceivedArguments = arguments
        resolveReceivedInvocations.append(arguments)
        return resolveReturnValue
    }
}

// MARK: - Public methods

extension PaymentSystemResolverMock {
    func fullReset() {
        resolveCallsCount = 0
        resolveReceivedArguments = nil
        resolveReceivedInvocations = []
    }
}
