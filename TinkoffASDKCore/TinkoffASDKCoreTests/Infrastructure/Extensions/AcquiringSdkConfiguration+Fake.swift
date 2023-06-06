//
//  AcquiringSdkConfiguration+Fake.swift
//  Pods
//
//  Created by Ivan Glushko on 06.06.2023.
//

import TinkoffASDKCore

extension AcquiringSdkConfiguration {
    static func fake() -> AcquiringSdkConfiguration {
        AcquiringSdkConfiguration(
            credential: .fake(),
            server: .test
        )
    }
}
