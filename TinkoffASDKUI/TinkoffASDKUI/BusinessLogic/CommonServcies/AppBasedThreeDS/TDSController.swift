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

import ThreeDSWrapper
import TinkoffASDKCore

typealias PaymentCompletionHandler = (_ result: Result<GetPaymentStatePayload, Error>) -> Void

protocol ITDSController: AnyObject {
    var completionHandler: PaymentCompletionHandler? { get set }
    var cancelHandler: (() -> Void)? { get set }

    /// Начинает испытание на стороне 3дс-сдк
    func doChallenge(with appBasedData: Confirmation3DS2AppBasedData)
}

final class TDSController: ITDSController {

    // Dependencies

    private let threeDsService: IAcquiringThreeDSService
    private let tdsWrapper: ITDSWrapper
    private let tdsTimeoutResolver: ITimeoutResolver

    // 3ds sdk properties

    private var transaction: ITransaction?
    private var progressView: ProgressDialog?
    private var challengeParams: ChallengeParameters?

    // Transaction completion handler

    var completionHandler: PaymentCompletionHandler?
    var cancelHandler: (() -> Void)?

    // Init

    init(
        threeDsService: IAcquiringThreeDSService,
        tdsWrapper: ITDSWrapper,
        tdsTimeoutResolver: ITimeoutResolver
    ) {
        self.threeDsService = threeDsService
        self.tdsWrapper = tdsWrapper
        self.tdsTimeoutResolver = tdsTimeoutResolver
    }

    /// Начинает испытание на стороне 3дс-сдк
    func doChallenge(with appBasedData: Confirmation3DS2AppBasedData) {
        let challengeParams = ChallengeParameters()

        challengeParams.setAcsTransactionId(appBasedData.acsTransId)
        challengeParams.set3DSServerTransactionId(appBasedData.tdsServerTransId)
        challengeParams.setAcsRefNumber(appBasedData.acsRefNumber)
        challengeParams.setAcsSignedContent(appBasedData.acsSignedContent)

        self.challengeParams = challengeParams
        transaction?.doChallenge(
            challengeParameters: challengeParams,
            challengeStatusReceiver: self,
            timeout: tdsTimeoutResolver.challengeValue
        )
    }

    func startAppBasedFlow(
        directoryServerID: String,
        messageVersion: String
    ) throws -> AuthenticationRequestParameters {
        let transaction = try tdsWrapper.createTransaction(
            directoryServerID: directoryServerID,
            messageVersion: messageVersion
        )
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

        return AuthenticationRequestParameters(
            deviceData: deviceDataBase64,
            sdkTransId: authParams.getSDKTransactionID(),
            sdkAppID: authParams.getSDKAppID(),
            sdkReferenceNum: authParams.getSDKReferenceNumber(),
            ephemeralPublic: sdkEphemPubKeyBase64
        )
    }
}

// MARK: - Private

private extension TDSController {

    func buildCresValue(with transStatus: String) throws -> String {
        guard let challengeParams = challengeParams else {
            return String()
        }
        let acsTransID = try challengeParams.getAcsTransactionId()
        let threeDSTransID = try challengeParams.get3DSServerTransactionId()

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
        do {
            let cresValue = try buildCresValue(with: completionEvent.getTransactionStatus())
            let cresData = CresData(cres: cresValue)

            threeDsService.submit3DSAuthorizationV2(data: cresData) { [weak self] result in
                self?.completionHandler?(result)
                self?.clear()
            }
        } catch {
            completionHandler?(.failure(error))
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

        completionHandler?(.failure(NSError(
            domain: errorDescription,
            code: errorCode
        )))
        clear()
    }

    func runtimeError(_ runtimeErrorEvent: RuntimeErrorEvent) {
        finishTransaction()
        let errorDescription = runtimeErrorEvent.getErrorMessage()
        let errorCode = Int(runtimeErrorEvent.getErrorCode()) ?? 1

        completionHandler?(.failure(NSError(
            domain: errorDescription,
            code: errorCode
        )))
        clear()
    }
}
