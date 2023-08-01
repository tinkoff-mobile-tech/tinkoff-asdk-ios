//
//  URLProtectionSpaceMock+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 01.08.2023.
//

import Foundation

extension URLProtectionSpaceMock {
    static func fake() -> URLProtectionSpaceMock {
        URLProtectionSpaceMock(
            host: "rest-api-test.tinkoff.ru",
            port: 443,
            protocol: "https",
            realm: nil,
            authenticationMethod: NSURLAuthenticationMethodServerTrust
        )
    }
}
