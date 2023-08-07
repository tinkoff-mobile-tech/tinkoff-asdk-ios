//
//  ThreeDsDataBrowser+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 04.08.2023.
//

import TinkoffASDKCore

extension ThreeDsDataBrowser {

    static func fake() -> Self {
        Self(
            threeDSCompInd: "Y",
            javaEnabled: "true",
            colorDepth: "32",
            language: "ru",
            timezone: "3",
            screenHeight: "100",
            screenWidth: "100",
            cresCallbackUrl: "cresCallbackUrl"
        )
    }
}
