//
//  ThreeDSDeviceInfo+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 07.07.2023.
//

@testable import TinkoffASDKCore

extension ThreeDSDeviceInfo {

    static func fake() -> ThreeDSDeviceInfo {
        ThreeDSDeviceInfo(
            threeDSCompInd: "Y",
            javaEnabled: "true",
            colorDepth: 32,
            language: "ru",
            timezone: 3,
            screenHeight: 100,
            screenWidth: 100,
            cresCallbackUrl: "cresCallbackUrl",
            sdkAppID: nil,
            sdkEphemPubKey: nil,
            sdkReferenceNumber: nil,
            sdkTransID: nil,
            sdkMaxTimeout: nil,
            sdkEncData: nil,
            sdkInterface: .both,
            sdkUiType: TdsSdkUiType.allValues()
        )
    }
}
