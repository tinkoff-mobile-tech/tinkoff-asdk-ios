//
//  File.swift
//  TinkoffASDKUI
//
//  Created by Никита Васильев on 14.07.2023.
//

import ThreeDSWrapper

protocol ICertificateState {
    var certificateType: ThreeDSWrapper.CertificateType { get }
    var directoryServerID: String { get }
    var algorithm: ThreeDSWrapper.CertificateAlgorithm { get }
    var source: ThreeDSWrapper.CertificateSource { get }
    var notAfterDate: Date { get }
    var sha256Fingerprint: String { get }
}

extension CertificateState: ICertificateState {}
