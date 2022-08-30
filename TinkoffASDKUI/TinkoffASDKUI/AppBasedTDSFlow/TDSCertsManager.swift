//
//
//  TDSCertsManager.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import TinkoffASDKCore
import ThreeDSWrapper

protocol ITDSCertsManager {
    /// Загружает сертификаты из конфига, сравнивает с сертами из ThreeDSWrapper и обновляет если необходимо
    func checkAndUpdateCertsIfNeeded(for paymentSystem: String,
                                     completion: @escaping (_ matchingDirectoryServerID: Result<String, Error>) -> Void)
}

final class TDSCertsManager: ITDSCertsManager {
    
    // Dependencies
    
    private let acquiringSdk: AcquiringSdk
    private let tdsWrapper: TDSWrapper
    
    // Init
    
    init(acquiringSdk: AcquiringSdk, tdsWrapper: TDSWrapper) {
        self.acquiringSdk = acquiringSdk
        self.tdsWrapper = tdsWrapper
    }
    
    func checkAndUpdateCertsIfNeeded(for paymentSystem: String,
                                     completion: @escaping (_ matchingDirectoryServerID: Result<String, Error>) -> Void) {
        acquiringSdk.getCertsConfig { [weak self] result in
            do {
                let certs = try result.get().certificates
                
                let matchingCerts = certs.filter { $0.paymentSystem == paymentSystem }
                
                guard let matchingDirectoryServerID = matchingCerts.first?.directoryServerID else {
                    completion(.failure(TDSFlowError.invalidPaymentSystem))
                    return
                }
                
                self?.compareAndUpdateWrapperCertsIfNeeded(with: matchingCerts, completion: { result in
                    completion(result.map { _ in matchingDirectoryServerID } )
                })
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private

private extension TDSCertsManager {

    func compareAndUpdateWrapperCertsIfNeeded(with configCerts: [CertificateData],
                                              completion: @escaping (Result<Void, Error>) -> Void) {
        let wrapperCertificates = tdsWrapper.checkCertificates()

        let updatingRequests = configCerts
            .filter { $0.forceUpdateFlag || shouldUpdate($0, wrapperCertificates) }
            .map(buildCertificateUpdatingRequest(from:))

        guard !updatingRequests.isEmpty else {
            return completion(.success(()))
        }

        tdsWrapper.update(with: updatingRequests, receiveOn: .main) { failures in
            if failures.isEmpty {
                completion(.success(()))
            } else {
                completion(.failure(TDSFlowError.updatingCertsError(failures)))
            }
        }
    }

    func shouldUpdate(_ configCert: CertificateData, _ wrapperCerts: [CertificateState]) -> Bool {
        !wrapperCerts.contains {
            $0.directoryServerID == configCert.directoryServerID
            && $0.certificateType == mapCertificateType(configCert.type)
            && $0.sha256Fingerprint == configCert.sha256Fingerprint
        }
    }

    func buildCertificateUpdatingRequest(from configCert: CertificateData) -> CertificateUpdatingRequest {
        CertificateUpdatingRequest(certificateType: mapCertificateType(configCert.type),
                                   directoryServerID: configCert.directoryServerID,
                                   algorithm: mapCertificateAlgorithm(configCert.algorithm),
                                   notAfterDate: configCert.notAfterDate,
                                   sha256Fingerprint: configCert.sha256Fingerprint,
                                   url: configCert.url)
    }

    func mapCertificateType(_ type: CertificateData.CertificateType) -> CertificateType {
        switch type {
        case .publicKey:
            return .dsPublicKey
        case .rootCA:
            return .dsRootCA
        }
    }
    
    func mapCertificateAlgorithm(_ algorithm: CertificateData.CertificateAlgorithm) -> CertificateAlgorithm {
        switch algorithm {
        case .rsa:
            return .rsa
        case .ec:
            return .ec
        }
    }
}
