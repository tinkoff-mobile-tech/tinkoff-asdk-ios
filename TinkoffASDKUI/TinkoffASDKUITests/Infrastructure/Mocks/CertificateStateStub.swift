//
//  CertificateStateStub.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 14.07.2023.
//

import Foundation
import ThreeDSWrapper
@testable import TinkoffASDKUI

final class CertificateStateMock: ICertificateState {

    var certificateType: CertificateType {
        get { return underlyingCertificateType }
        set(value) { underlyingCertificateType = value }
    }

    var underlyingCertificateType: CertificateType = .dsPublicKey

    var directoryServerID: String {
        get { return underlyingDirectoryServerID }
        set(value) { underlyingDirectoryServerID = value }
    }

    var underlyingDirectoryServerID = "directoryServerID"

    var algorithm: CertificateAlgorithm {
        get { return underlyingAlgorithm }
        set(value) { underlyingAlgorithm = value }
    }

    var underlyingAlgorithm: CertificateAlgorithm = .ec

    var source: CertificateSource {
        get { return underlyingSource }
        set(value) { underlyingSource = value }
    }

    var underlyingSource: CertificateSource = .bundle

    var notAfterDate: Date {
        get { return underlyingNotAfterDate }
        set(value) { underlyingNotAfterDate = value }
    }

    var underlyingNotAfterDate = Date()

    var sha256Fingerprint: String {
        get { return underlyingSha256Fingerprint }
        set(value) { underlyingSha256Fingerprint = value }
    }

    var underlyingSha256Fingerprint = ""
}
