//
//  AcquiringSdk+Fake.swift
//  Pods
//
//  Created by Ivan Glushko on 06.06.2023.
//

import TinkoffASDKCore

extension AcquiringSdk {

    static func fake() -> AcquiringSdk {
        try! AcquiringSdk(configuration: .fake())
    }
}
