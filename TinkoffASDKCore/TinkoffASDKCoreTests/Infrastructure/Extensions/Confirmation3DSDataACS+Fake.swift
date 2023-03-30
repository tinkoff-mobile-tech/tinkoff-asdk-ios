//
//  Confirmation3DSDataACS+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 28.03.2023.
//

@testable import TinkoffASDKCore

/// 3DS v2
public extension Confirmation3DSDataACS {

    static func fake() -> Self {
        Confirmation3DSDataACS(
            acsUrl: "https://tinkoff.ru",
            acsTransId: "acsTransId",
            tdsServerTransId: "tdsServerTransId"
        )
    }
}
