//
//  CertificateValidator.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 13.03.2023.
//

import Foundation
import Security

public final class CertificateValidator: ICertificateValidator {
    // MARK: Properties

    public static let shared: ICertificateValidator = CertificateValidator()

    private lazy var certificates = ["RussianTrustedRootCA", "RussianTrustedSubCA"].compactMap { certificate(name: $0) }

    // MARK: Initialization

    private init() {}

    // MARK: ICertificateValidator

    public func isValid(serverTrust: SecTrust) -> Bool {
        SecTrustSetAnchorCertificates(serverTrust, certificates as CFArray)
        SecTrustSetAnchorCertificatesOnly(serverTrust, false)
        return SecTrustEvaluateWithError(serverTrust, nil)
    }
}

// MARK: - Private

extension CertificateValidator {
    private func certificate(name: String) -> SecCertificate? {
        guard let path = Bundle.core.url(forResource: name, withExtension: "der"),
              let certData = try? Data(contentsOf: path) else {
            return nil
        }

        return SecCertificateCreateWithData(nil, certData as CFData)
    }
}
