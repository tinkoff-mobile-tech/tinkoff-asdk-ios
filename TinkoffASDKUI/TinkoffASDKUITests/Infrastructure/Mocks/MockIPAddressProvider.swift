//
//  MockIPAddressProvider.swift
//  Pods
//
//  Created by Ivan Glushko on 19.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class MockIPAddressProvider: IIPAddressProvider, IPAddress {

    public var ipAddress: IPAddress? {
        self
    }

    // MARK: - IPAddress

    let stringValue: String
    let fullStringValue: String

    init?(_ stringValue: String) {
        self.stringValue = stringValue
        fullStringValue = stringValue + "FULL"
    }

    init() {
        let value = "ipAddressValue"
        stringValue = value
        fullStringValue = value + "FULL"
    }
}
