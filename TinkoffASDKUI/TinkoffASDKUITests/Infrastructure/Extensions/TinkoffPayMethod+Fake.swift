//
//  TinkoffPayMethod+Fake.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 29.05.2023.
//

import TinkoffASDKCore

extension TinkoffPayMethod {
    static func fake(version: String? = nil) -> TinkoffPayMethod {
        TinkoffPayMethod(version: version ?? "1.1.1")
    }
}
