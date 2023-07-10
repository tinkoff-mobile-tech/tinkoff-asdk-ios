//
//  Check3DSVersionPayload+Fake.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 30.06.2023.
//

@testable import TinkoffASDKCore

extension Check3DSVersionPayload {
    static func fake(version: ThreeDSVersion) -> Check3DSVersionPayload {
        switch version {
        case .v1:
            return Check3DSVersionPayload(
                version: "1.0.0",
                tdsServerTransID: nil,
                threeDSMethodURL: nil,
                paymentSystem: nil
            )

        case .v2:
            return Check3DSVersionPayload(
                version: "2.0.0",
                tdsServerTransID: "tdsServerTransID",
                threeDSMethodURL: "threeDSMethodURL",
                paymentSystem: nil
            )
        case .appBased:
            return Check3DSVersionPayload(
                version: "2.1.0",
                tdsServerTransID: "tdsServerTransID",
                threeDSMethodURL: "threeDSMethodURL",
                paymentSystem: "mock"
            )
        }
    }
}
