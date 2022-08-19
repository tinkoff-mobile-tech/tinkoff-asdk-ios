//
//
//  TDSController.swift
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

final class TDSController {
    
    // Dependencies
    
    private let acquiringSdk: AcquiringSdk
    private let tdsWrapper: TDSWrapper
    private let tdsCertsManager: ITDSCertsManager
    
    // 3ds sdk properties
    
    private var transaction: Transaction?
    private var progressView: ProgressDialog?
    private var challengeParams: ChallengeParameters?
    
    // Transaction completion handler
    
    var completionHandler: PaymentCompletionHandler?
    var cancelHandler: (() -> Void)?
    
    // Init
    
    init(acquiringSdk: AcquiringSdk,
         tdsWrapper: TDSWrapper,
         tdsCertsManager: ITDSCertsManager) {
        self.acquiringSdk = acquiringSdk
        self.tdsWrapper = tdsWrapper
        self.tdsCertsManager = tdsCertsManager
    }
    
    /// Получает необходимые параметры для проведения 3дс
    func obtainAuthParams(with paymentSystem: String,
                          messageVersion: String,
                          completion: @escaping (Result<AuthenticationRequestParameters, Error>) -> Void) {
        tdsCertsManager.checkAndUpdateCertsIfNeeded(for: paymentSystem) { result in
            do {
                let matchingDirectoryServerID = try result.get()
                let authParams = try self.startAppBasedFlow(directoryServerID: matchingDirectoryServerID,
                                                             messageVersion: messageVersion)
                completion(.success(authParams))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Начинает испытание на стороне 3дс-сдк
    func doChallenge(with challengeParams: ChallengeParameters, timeout: Int) {
        self.challengeParams = challengeParams
        transaction?.doChallenge(challengeParameters: challengeParams,
                                 challengeStatusReceiver: self,
                                 timeout: timeout)
    }
}

// MARK: - Private

private extension TDSController {
    
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
    
    func finishTransaction() {
        transaction?.close()
        DispatchQueue.main.async {
            self.progressView?.close()
        }
    }
    
    func clear() {
        transaction = nil
        progressView = nil
        challengeParams = nil
    }
}

// MARK: - ChallengeStatusReceiver Delegate

extension TDSController: ChallengeStatusReceiver {
    func completed(_ completionEvent: CompletionEvent) {
        finishTransaction()
        let cresValue = buildCresValue(with: completionEvent.getTransactionStatus())
        acquiringSdk.submit3DSAuthorizationV2(cres: cresValue) { [weak self] result in
            self?.completionHandler?(result)
            self?.clear()
        }
    }
    
    func cancelled() {
        finishTransaction()
        cancelHandler?()
        clear()
    }
    
    func timedout() {
        finishTransaction()
        completionHandler?(.failure(TDSFlowError.timeout))
        clear()
    }
    
    func protocolError(_ protocolErrorEvent: ProtocolErrorEvent) {
        finishTransaction()
        let errorDescription = protocolErrorEvent.getErrorMessage().getErrorDescription()
        let errorCode = Int(protocolErrorEvent.getErrorMessage().getErrorCode()) ?? 1
        
        completionHandler?(.failure(NSError(domain: errorDescription,
                                            code: errorCode)))
        clear()
    }
    
    func runtimeError(_ runtimeErrorEvent: RuntimeErrorEvent) {
        finishTransaction()
        let errorDescription = runtimeErrorEvent.getErrorMessage()
        let errorCode = Int(runtimeErrorEvent.getErrorCode()) ?? 1
        
        completionHandler?(.failure(NSError(domain: errorDescription,
                                            code: errorCode)))
        clear()
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
