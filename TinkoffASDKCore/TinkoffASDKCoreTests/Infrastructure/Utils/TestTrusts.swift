//
//  TestTrusts.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 01.08.2023.
//

import Foundation

struct TestTrusts {
    static let trust: SecTrust = {
        var trust: SecTrust?
        SecTrustCreateWithCertificates(TestCertificates.certChain as CFTypeRef, nil, &trust)
        return trust!
    }()
}
