//
//  Checking3DSURLData+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 19.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

extension Checking3DSURLData {
    static func fake(threeDSMethodURL: String = URL.doesNotMatter.absoluteString) -> Checking3DSURLData {
        Checking3DSURLData(
            tdsServerTransID: "tdsServerTransID",
            threeDSMethodURL: threeDSMethodURL,
            notificationURL: "notificationURL"
        )
    }
}
