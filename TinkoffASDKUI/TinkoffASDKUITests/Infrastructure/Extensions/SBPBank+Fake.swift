//
//  SBPBank+Fake.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 28.06.2023.
//

import TinkoffASDKCore

extension SBPBank {
    static func fake() -> SBPBank {
        SBPBank(name: "name", logoURL: nil, schema: "schema")
    }
}
