//
//  CardOptions+Fake.swift
//  TinkoffASDKUITests
//
//  Created by Ivan Glushko on 03.04.2023
//

import TinkoffASDKUI

extension CardOptions {

    static func fake() -> Self {
        CardOptions(pan: "123123123123", validThru: "0928", cvc: "123")
    }
}
