//
//  TestCertificates.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 01.08.2023.
//

import Foundation

struct TestCertificates {
    static let certChain: [SecCertificate] = {
        ["RootCA"].map { certNamed($0) }
    }()

    static func certNamed(_ name: String) -> SecCertificate {
        class TestBundle {}

        let bundle = Bundle(for: TestBundle.self)
        let url = bundle.url(forResource: name, withExtension: "der")
        let data = try? Data(contentsOf: url!)
        return SecCertificateCreateWithData(nil, data! as CFData)!
    }
}
