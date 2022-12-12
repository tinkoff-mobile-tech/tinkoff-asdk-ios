//
//  MockPaymentSystemResolver.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation

final class MockPaymentSystemResolver: IPaymentSystemResolver {

    var resolveCallCounter = 0
    var resolveStub: (_ inputPan: String?) -> PaymentSystemDecision = { _ in
        .unrecognized
    }

    func resolve(by inputPAN: String?) -> PaymentSystemDecision {
        resolveCallCounter += 1
        return resolveStub(inputPAN)
    }
}
