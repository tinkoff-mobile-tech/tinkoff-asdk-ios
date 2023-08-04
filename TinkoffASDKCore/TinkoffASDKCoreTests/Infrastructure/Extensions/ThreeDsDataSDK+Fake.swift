//
//  ThreeDsDataSDK+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 07.07.2023.
//

@testable import TinkoffASDKCore

extension ThreeDsDataSDK {
    static func fake() -> Self {
        Self(
            sdkAppID: "sdkAppID",
            sdkEphemPubKey: "sdkEphemPubKey",
            sdkReferenceNumber: "sdkReferenceNumber",
            sdkTransID: "sdkTransID",
            sdkMaxTimeout: "sdkMaxTimeout",
            sdkEncData: "sdkEncData",
            sdkInterface: .both,
            sdkUiType: "sdkUiType"
        )
    }
}
