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
        acquiringSdk.getConfig { [weak self] result in
            do {
                let certs = try result.get().certificates
                
                let matchingCerts = certs.filter { $0.paymentSystem == paymentSystem }
                
                guard let matchingDirectoryServerID = matchingCerts.first?.directoryServerID else {
                    completion(.failure(TDSFlowError.invalidPaymentSystem))
                    return
                }
                
                self?.compareAndUpdateWrapperCertsIfNeeded(with: matchingCerts, completion: { result in
                    do {
                        _ = try result.get()
                        completion(.success(matchingDirectoryServerID))
                    } catch {
                        completion(.failure(error))
                    }
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
        var certificateUpdatingRequests = [CertificateUpdatingRequest]()
        
        configCerts.forEach {
            guard let wrapperMatchingCert = getWrapperMatchingCert(for: $0.directoryServerID, type: $0.type) else {
                return
            }
            
            if wrapperMatchingCert.sha256Fingerprint != $0.sha256Fingerprint || $0.forceUpdateFlag {
                do {
                    let certificateUpdatingRequest = try buildCertificateUpdatingRequest(from: $0)
                    certificateUpdatingRequests.append(certificateUpdatingRequest)
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        guard !certificateUpdatingRequests.isEmpty else {
            completion(.success(()))
            return
        }
        
        tdsWrapper.update(with: certificateUpdatingRequests, receiveOn: .main) { result in
            if result.isEmpty {
                completion(.success(()))
            } else {
                completion(.failure(TDSFlowError.updatingCertsError(result)))
            }
        }
    }

    
    func buildCertificateUpdatingRequest(from configCert: CertificateData) throws -> CertificateUpdatingRequest {
        guard let url = URL(string: configCert.url),
              let notAfterDate = ISO8601DateFormatter.certsInput.date(from: configCert.notAfterDate) else {
            throw TDSFlowError.invalidConfigCertParams
        }
        
        return CertificateUpdatingRequest(certificateType: mapCertificateType(configCert.type),
                                          directoryServerID: configCert.directoryServerID,
                                          algorithm: mapCertificateAlgorithm(configCert.algorithm),
                                          notAfterDate: notAfterDate,
                                          sha256Fingerprint: configCert.sha256Fingerprint,
                                          url: url)
    }
    
    func getWrapperMatchingCert(for directoryServerID: String, type: CertificateData.CertificateType) -> CertificateState? {
        tdsWrapper.checkCertificates().first {
            $0.directoryServerID == directoryServerID && $0.certificateType == mapCertificateType(type)
        }
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

private extension ISO8601DateFormatter {
    /// Certs notAfterDate field formatter
    static let certsInput: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime
        ]
        return dateFormatter
    }()
}
