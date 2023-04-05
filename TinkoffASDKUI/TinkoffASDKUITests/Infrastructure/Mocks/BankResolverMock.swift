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

    var resolveCallCounter = 0
    var resolveStub: (_ cardNumber: String?) -> BankResult = { _ in .incorrectInput(error: .noValue)
    }

    func resolve(cardNumber: String?) -> BankResult {
        resolveCallCounter += 1
        return resolveStub(cardNumber)
    }
}
