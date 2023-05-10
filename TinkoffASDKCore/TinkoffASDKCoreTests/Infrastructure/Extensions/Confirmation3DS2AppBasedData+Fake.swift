//
//  Confirmation3DS2AppBasedData+Fake.swift
//  Pods
//
//  Created by Ivan Glushko on 21.04.2023.
//

@testable import TinkoffASDKCore

extension Confirmation3DS2AppBasedData {

    static func fake() -> Confirmation3DS2AppBasedData {
        Confirmation3DS2AppBasedData(
            acsSignedContent: "acsSignedContent",
            acsTransId: "acsTransId",
            tdsServerTransId: "tdsServerTransId",
            acsRefNumber: "acsRefNumber"
        )
    }
}
