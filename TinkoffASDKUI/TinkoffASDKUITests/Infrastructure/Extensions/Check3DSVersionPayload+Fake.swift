//
//  Check3DSVersionPayload+Fake.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 30.06.2023.
//

@testable import TinkoffASDKCore

extension Check3DSVersionPayload {
    static func fake() -> Check3DSVersionPayload {
        Check3DSVersionPayload(
            version: "",
            tdsServerTransID: "",
            threeDSMethodURL: "",
            paymentSystem: ""
        )
    }
}
