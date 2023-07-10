//
//  ThreeDSDeviceInfo+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 07.07.2023.
//

@testable import TinkoffASDKCore

extension ThreeDSDeviceInfo {

    static func fake() -> ThreeDSDeviceInfo {
        ThreeDSDeviceInfo(cresCallbackUrl: "cresCallbackUrl", screenWidth: 100, screenHeight: 100)
    }
}
