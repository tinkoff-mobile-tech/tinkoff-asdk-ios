//
//  Confirmation3DSDataACS+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 28.03.2023.
//

@testable import TinkoffASDKCore

/// 3DS v1
public extension Confirmation3DSData {

    static func fake() -> Self {
        Confirmation3DSData(
            acsUrl: "https://tinkoff.ru",
            pareq: "pareq",
            md: "md"
        )
    }
}
