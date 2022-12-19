//
//  MockPaymentSystemImageResolver.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 19.12.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation

final class MockPaymentSystemImageResolver: IPaymentSystemImageResolver {

    var resolveCallCounter = 0
    var resolveStub: (String?) -> UIImage? = { _ in nil }
    func resolve(by inputPAN: String?) -> UIImage? {
        resolveCallCounter += 1
        return resolveStub(inputPAN)
    }
}
