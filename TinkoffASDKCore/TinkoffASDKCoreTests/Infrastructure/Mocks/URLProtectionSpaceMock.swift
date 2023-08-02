//
//  URLProtectionSpaceMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 01.08.2023.
//

import Foundation
@testable import TinkoffASDKCore

class URLProtectionSpaceMock: URLProtectionSpace {
    var internalServerTrust: SecTrust?

    override var serverTrust: SecTrust? {
        internalServerTrust
    }
}
