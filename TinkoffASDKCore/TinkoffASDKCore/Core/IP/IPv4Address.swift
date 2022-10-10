//
//  IPv4Address.swift
//  TinkoffASDKCore
//
//  Created by grisha on 09.12.2020.
//

import Foundation

struct IPv4Address: TinkoffASDKCore.IPAddress {
    var stringValue: String

    var fullStringValue: String {
        return stringValue
    }

    init?(_ stringValue: String) {
        let validator = IPAddressValidator()
        guard validator.validateIPAddress(stringValue, type: .v4) else {
            return nil
        }
        self.stringValue = stringValue
    }
}
