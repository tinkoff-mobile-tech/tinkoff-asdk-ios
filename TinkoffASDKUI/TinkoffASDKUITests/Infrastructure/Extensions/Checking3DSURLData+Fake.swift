//
//  Checking3DSURLData+Fake.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 22.06.2023.
//

import TinkoffASDKCore

extension Checking3DSURLData {
    static func fake() -> Checking3DSURLData {
        Checking3DSURLData(
            tdsServerTransID: "tdsServerTransID",
            threeDSMethodURL: "method",
            notificationURL: "notification"
        )
    }
}
