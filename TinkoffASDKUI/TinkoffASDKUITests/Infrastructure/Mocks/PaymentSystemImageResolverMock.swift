//
//  PaymentSystemImageResolverMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 19.12.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import UIKit

final class PaymentSystemImageResolverMock: IPaymentSystemImageResolver {

    // MARK: - resolve

    typealias ResolveArguments = String

    var resolveCallsCount = 0
    var resolveReceivedArguments: ResolveArguments?
    var resolveReceivedInvocations: [ResolveArguments?] = []
    var resolveReturnValue: UIImage?

    func resolve(by inputPAN: String?) -> UIImage? {
        resolveCallsCount += 1
        let arguments = inputPAN
        resolveReceivedArguments = arguments
        resolveReceivedInvocations.append(arguments)
        return resolveReturnValue
    }
}

// MARK: - Resets

extension PaymentSystemImageResolverMock {
    func fullReset() {
        resolveCallsCount = 0
        resolveReceivedArguments = nil
        resolveReceivedInvocations = []
    }
}
