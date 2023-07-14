//
//  CertificateStateStub.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 14.07.2023.
//

import Foundation
import ThreeDSWrapper
@testable import TinkoffASDKUI

struct CertificateStateStub: ICertificateState {
    let certificateType: ThreeDSWrapper.CertificateType
    let directoryServerID: String
    let algorithm: ThreeDSWrapper.CertificateAlgorithm
    let source: ThreeDSWrapper.CertificateSource
    let notAfterDate: Date
    let sha256Fingerprint: String

    init(
        certificateType: ThreeDSWrapper.CertificateType = .dsPublicKey,
        directoryServerID: String = "directoryServerID",
        algorithm: ThreeDSWrapper.CertificateAlgorithm = .ec,
        source: ThreeDSWrapper.CertificateSource = .bundle,
        notAfterDate: Date = Date(),
        sha256Fingerprint: String = ""
    ) {
        self.certificateType = certificateType
        self.directoryServerID = directoryServerID
        self.algorithm = algorithm
        self.source = source
        self.notAfterDate = notAfterDate
        self.sha256Fingerprint = sha256Fingerprint
    }
}
