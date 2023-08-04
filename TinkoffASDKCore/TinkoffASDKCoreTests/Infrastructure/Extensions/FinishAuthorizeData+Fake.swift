//
//  FinishAuthorizeData+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

extension FinishAuthorizeData {
    static func fake() -> FinishAuthorizeData {
        FinishAuthorizeData(
            paymentId: "id",
            paymentSource: .savedCard(cardId: "123", cvv: "213"),
            infoEmail: nil,
            amount: nil,
            data: nil
        )
    }
}
