//
//
//  AppBasedThreeDSController.swift
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

final class AppBasedThreeDSController {
    
    // MARK: - Dependencies
    
    private let tdsWrapper: TDSWrapper
    private let acquiringSdk: AcquiringSdk
    
    // MARK: - 3ds sdk properties
    
    private var transaction: Transaction?
    private var progressView: ProgressDialog?
    private var challengeParams: ChallengeParameters?
    
    // MARK: - Transaction completion handler
    
    var completionHandler: PaymentCompletionHandler?
    var cancelHandler: (() -> Void)?
    
    // MARK: - Init
    
    init(acquiringSdk: AcquiringSdk,
         env: AcquiringSdkEnvironment,
         language: AcquiringSdkLanguage?) {
        let locale: Locale
        
        switch language {
        case .ru:
            locale = Locale(identifier: .russian)
        case .en:
            locale = Locale(identifier: .english)
        default:
            locale = Locale(identifier: .russian)
        }
        
        let sdkConfiguration = TDSWrapper.SDKConfiguration(uiCustomization: nil,
                                                           locale: locale)
        self.tdsWrapper = TDSWrapper(sdkConfiguration: sdkConfiguration,
                                     wrapperConfiguration: .init(environment: env == .test ? .test : .production))
        self.acquiringSdk = acquiringSdk
    }
    
    enum AppBasedFlowError: Swift.Error {
        case invalidPaymentSystem
        case invalidDirectoryServerID
        case invalidConfigCertParams
        case updatingCertsError([CertificateUpdatingRequest : TDSWrapperError])
        case timeout
    }
    
    func obtainAuthParams(with paymentSystem: String,
                          messageVersion: String,
                          completion: @escaping (Result<AuthenticationRequestParameters, Error>) -> Void) {
        acquiringSdk.getConfig { [weak self] result in
            do {
                let certs = try result.get().certificates
                
                let matchingCerts = certs.filter { $0.paymentSystem == paymentSystem }
                
                guard let matchingDirectoryServerID = matchingCerts.first?.directoryServerID else {
                    completion(.failure(AppBasedFlowError.invalidPaymentSystem))
                    return
                }
                
                self?.compareAndUpdateWrapperCertsIfNeeded(with: matchingCerts, completion: { [weak self] result in
                    do {
                        guard let self = self else { return }
                        _ = try result.get()
                        let authParams = try self.startAppBasedFlow(directoryServerID: matchingDirectoryServerID,
                                                                     messageVersion: messageVersion)
                        completion(.success(authParams))
                    } catch {
                        completion(.failure(error))
                    }
                })
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func doChallenge(with challengeParams: ChallengeParameters, timeout: Int) {
        self.challengeParams = challengeParams
        transaction?.doChallenge(challengeParameters: challengeParams,
                                 challengeStatusReceiver: self,
                                 timeout: timeout)
    }
}

// MARK: - Private

private extension AppBasedThreeDSController {
    
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
                completion(.failure(AppBasedFlowError.updatingCertsError(result)))
            }
        }
    }
    
    func startAppBasedFlow(directoryServerID: String,
                           messageVersion: String) throws -> AuthenticationRequestParameters {
        let transaction = try tdsWrapper.createTransaction(directoryServerID: directoryServerID,
                                                       messageVersion: messageVersion)
        self.transaction = transaction
        
        DispatchQueue.main.async {
            self.progressView = transaction.getProgressView()
            self.progressView?.start()
        }
                
        let authParams = try transaction.getAuthenticationRequestParameters()
        
        let deviceDataString = authParams.getDeviceData()
        let deviceDataBase64 = Data(deviceDataString.utf8).base64EncodedString()
        
        let sdkEphemPubKey = authParams.getSDKEphemeralPublicKey()
        let sdkEphemPubKeyBase64 = Data(sdkEphemPubKey.utf8).base64EncodedString()
        
        return AuthenticationRequestParameters(deviceData: deviceDataBase64,
                                               sdkTransId: authParams.getSDKTransactionID(),
                                               sdkAppID: authParams.getSDKAppID(),
                                               sdkReferenceNum: authParams.getSDKReferenceNumber(),
                                               ephemeralPublic: sdkEphemPubKeyBase64)
    }
    
    func getWrapperMatchingCert(for directoryServerID: String, type: String) -> CertificateState? {
        tdsWrapper.checkCertificates().first {
            $0.directoryServerID == directoryServerID && $0.certificateType == CertificateType(rawValue: type)
        }
    }
    
    func buildCresValue(with transStatus: String) -> String {
        guard let acsTransID = try? challengeParams?.getAcsTransactionId(),
              let threeDSTransID = try? challengeParams?.get3DSServerTransactionId() else {
            return String()
        }
        
        let cresValue = "{\"threeDSServerTransID\":\"\(threeDSTransID)\",\"acsTransID\":\"\(acsTransID)\",\"transStatus\":\"\(transStatus)\"}"
        let encodedString = Data(cresValue.utf8).base64EncodedString()
        
        let noPaddingEncodedString = encodedString.replacingOccurrences(of: "=", with: "")
        
        return noPaddingEncodedString
    }
    
    func buildCertificateUpdatingRequest(from configCert: CertificateData) throws -> CertificateUpdatingRequest {
        guard let type = CertificateType(rawValue: configCert.type),
              let url = URL(string: configCert.url),
              let notAfterDate = ISO8601DateFormatter.input.date(from: configCert.notAfterDate) else {
            throw AppBasedFlowError.invalidConfigCertParams
        }
        
        let algorithm: CertificateAlgorithm
        switch configCert.algorithm {
        case "RSA":
            algorithm = .rsa
        case "EC":
            algorithm = .ec
        default:
            algorithm = .rsa
        }
        
        return CertificateUpdatingRequest(certificateType: type,
                                          directoryServerID: configCert.directoryServerID,
                                          algorithm: algorithm,
                                          notAfterDate: notAfterDate,
                                          sha256Fingerprint: configCert.sha256Fingerprint,
                                          url: url)
    }
    
    func finishTransaction() {
        transaction?.close()
        DispatchQueue.main.async {
            self.progressView?.close()
        }
    }
}

// MARK: - ChallengeStatusReceiver Delegate

extension AppBasedThreeDSController: ChallengeStatusReceiver {
    func completed(_ completionEvent: CompletionEvent) {
        finishTransaction()
        let cresValue = buildCresValue(with: completionEvent.getTransactionStatus())
        acquiringSdk.submit3DSAuthorizationV2(cres: cresValue) { [weak self] result in
            self?.completionHandler?(result)
        }
    }
    
    func cancelled() {
        finishTransaction()
        cancelHandler?()
    }
    
    func timedout() {
        finishTransaction()
        completionHandler?(.failure(AppBasedFlowError.timeout))
    }
    
    func protocolError(_ protocolErrorEvent: ProtocolErrorEvent) {
        finishTransaction()
        let errorDescription = protocolErrorEvent.getErrorMessage().getErrorDescription()
        let errorCode = Int(protocolErrorEvent.getErrorMessage().getErrorCode()) ?? 1
        
        completionHandler?(.failure(NSError(domain: errorDescription,
                                            code: errorCode)))
    }
    
    func runtimeError(_ runtimeErrorEvent: RuntimeErrorEvent) {
        finishTransaction()
        let errorDescription = runtimeErrorEvent.getErrorMessage()
        let errorCode = Int(runtimeErrorEvent.getErrorCode()) ?? 1
        
        completionHandler?(.failure(NSError(domain: errorDescription,
                                            code: errorCode)))
    }
}

extension ISO8601DateFormatter {

    static let input: ISO8601DateFormatter = {
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

// MARK: - Locale identifiers

private extension String {
    static let russian = "ru_RU"
    static let english = "en_US"
}
