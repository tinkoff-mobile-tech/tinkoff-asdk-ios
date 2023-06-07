//
//  AcquiringUISDK+Fake.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 02.06.2023.
//

import TinkoffASDKCore
import TinkoffASDKUI

extension AcquiringUISDK {

    static func fake() -> AcquiringUISDK {
        return try! AcquiringUISDK(
            coreSDKConfiguration: .fake()
        )
    }
}
