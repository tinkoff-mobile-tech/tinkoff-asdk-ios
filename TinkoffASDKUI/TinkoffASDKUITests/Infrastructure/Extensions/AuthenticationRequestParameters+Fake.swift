//
//  AuthenticationRequestParameters+Fake.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 07.07.2023.
//

import TdsSdkIos

extension AuthenticationRequestParameters {

    static func fake() -> AuthenticationRequestParameters {
        AuthenticationRequestParameters(
            deviceData: "deviceData",
            sdkTransId: "sdkTransId",
            sdkAppID: "sdkAppID",
            sdkReferenceNum: "sdkReferenceNum",
            ephemeralPublic: "ephemeralPublic"
        )
    }
}
