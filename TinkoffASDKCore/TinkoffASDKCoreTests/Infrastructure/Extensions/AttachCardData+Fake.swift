//
//  AttachCardData+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 27.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

extension AttachCardData {
    static func fake() -> AttachCardData {
        AttachCardData(cardNumber: "22001234556789010", expDate: "2020-08-11", cvv: "231", requestKey: "key")
    }
}
