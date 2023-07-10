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

/// Используется для проведения транзакции 3дс через App Based Flow
protocol ITDSController: AnyObject {
    var completionHandler: PaymentCompletionHandler? { get set }
    var cancelHandler: (() -> Void)? { get set }

    /// 1. Запускает App Based Flow проверку
    func startAppBasedFlow(
        check3dsPayload: Check3DSVersionPayload,
        completion: @escaping (Result<ThreeDSDeviceInfo, Error>) -> Void
    )

    /// 2. Начинает испытание на стороне 3дс-сдк
    func doChallenge(with appBasedData: Confirmation3DS2AppBasedData)

    /// Приостанавливает выполнение транзакции
    ///
    /// Используем в случае получения ошибок от асдк
    func stop()
}

final class TDSController: ITDSController {

    // Dependencies

    private let threeDsService: IAcquiringThreeDSService
    private let tdsWrapper: ITDSWrapper
    private let tdsTimeoutResolver: ITimeoutResolver
    private let tdsCertsManager: ITDSCertsManager
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private let mainQueue: any IDispatchQueue

    // TODO: EACQAPW-5434 Убрать костыль задержки в TDSController
    // Костыль нужен для решения проблемы одновременных анимаций модалок.
    // Из-за этого не показывается шторка асдк с ошибкой оплаты
    private let delayExecutor: IDelayedExecutor

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
        tdsTimeoutResolver: ITimeoutResolver,
        tdsCertsManager: ITDSCertsManager,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider,
        delayExecutor: IDelayedExecutor,
        mainQueue: IDispatchQueue
    ) {
        self.threeDsService = threeDsService
        self.tdsWrapper = tdsWrapper
        self.tdsTimeoutResolver = tdsTimeoutResolver
        self.tdsCertsManager = tdsCertsManager
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
        self.delayExecutor = delayExecutor
        self.mainQueue = mainQueue
    }

    /// Запускает App Based Flow проверку
    func startAppBasedFlow(
        check3dsPayload: Check3DSVersionPayload,
        completion: @escaping (Result<ThreeDSDeviceInfo, Error>) -> Void
    ) {
        guard let paymentSystem = check3dsPayload.paymentSystem
        else {
            completion(.failure(AppBasedControllerError.noPaymentSystem))
            return
        }

        getDeviceInfo(
            paymentSystem: paymentSystem,
            messageVersion: check3dsPayload.version,
            completion: completion
        )
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

    func stop() {
        finishTransaction()
        clear()
    }
}

// MARK: - Private

extension TDSController {

    /// Получает необходимые параметры для проведения 3дс
    private func getDeviceInfo(
        paymentSystem: String,
        messageVersion: String,
        completion: @escaping (Result<ThreeDSDeviceInfo, Error>) -> Void
    ) {
        tdsCertsManager.checkAndUpdateCertsIfNeeded(for: paymentSystem) { [weak self] result in
            guard let self = self else { return }

            do {
                let matchingDirectoryServerID = try result.get()
                // getting auth params
                let authParams = try self.startTransaction(
                    directoryServerID: matchingDirectoryServerID,
                    messageVersion: messageVersion
                )

                // enriching request with additional params
                let deviceInfo = self.gatherThreeDSDeviceInfo(
                    messageVersion: messageVersion,
                    authParams: authParams
                )

                completion(.success(deviceInfo))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Добавляет необходимые параметры в `FinishAuthorizeData`
    private func gatherThreeDSDeviceInfo(
        messageVersion: String,
        authParams: AuthenticationRequestParameters
    ) -> ThreeDSDeviceInfo {
        let deviceInfoFromProvider = threeDSDeviceInfoProvider.deviceInfo
        return ThreeDSDeviceInfo(
            threeDSCompInd: deviceInfoFromProvider.threeDSCompInd,
            cresCallbackUrl: deviceInfoFromProvider.cresCallbackUrl,
            languageId: deviceInfoFromProvider.language,
            screenWidth: deviceInfoFromProvider.screenWidth,
            screenHeight: deviceInfoFromProvider.screenHeight,
            sdkAppID: authParams.getSDKAppID(),
            sdkEphemPubKey: authParams.getSDKEphemeralPublicKey(),
            sdkReferenceNumber: authParams.getSDKReferenceNumber(),
            sdkTransID: authParams.getSDKTransactionID(),
            sdkMaxTimeout: tdsTimeoutResolver.mapiValue,
            sdkEncData: authParams.getDeviceData()
        )
    }

    /// Запускаем app based flow сценарий
    private func startTransaction(
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

    private func sendCompletionWithDelay(result: Result<GetPaymentStatePayload, Error>) {
        delayExecutor.execute { [weak self] in
            guard let self = self else { return }
            self.completionHandler?(result)
        }
    }

    private func buildCresValue(with transStatus: String) throws -> String {
        guard let challengeParams = challengeParams else { return "" }
        let acsTransID = try challengeParams.getAcsTransactionId()
        let threeDSTransID = try challengeParams.get3DSServerTransactionId()

        let cresValue = "{\"threeDSServerTransID\":\"\(threeDSTransID)\",\"acsTransID\":\"\(acsTransID)\",\"transStatus\":\"\(transStatus)\"}"

        let encodedString = Data(cresValue.utf8).base64EncodedString()
        let noPaddingEncodedString = encodedString.replacingOccurrences(of: "=", with: "")
        return noPaddingEncodedString
    }

    private func finishTransaction() {
        type(of: mainQueue).performOnMain {
            self.progressView?.stop()
            self.transaction?.close()
        }
    }

    private func clear() {
        if transaction != nil { transaction = nil }
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
        delayExecutor.execute { [weak self] in
            self?.cancelHandler?()
        }
        clear()
    }

    func timedout() {
        finishTransaction()
        sendCompletionWithDelay(result: .failure(TDSFlowError.timeout))
        clear()
    }

    func protocolError(_ protocolErrorEvent: ProtocolErrorEvent) {
        finishTransaction()
        let errorDescription = protocolErrorEvent.getErrorMessage().getErrorDescription()
        let errorCode = Int(protocolErrorEvent.getErrorMessage().getErrorCode()) ?? 1
        let error = NSError(domain: errorDescription, code: errorCode)
        sendCompletionWithDelay(result: .failure(error))
        clear()
    }

    func runtimeError(_ runtimeErrorEvent: RuntimeErrorEvent) {
        finishTransaction()
        let errorDescription = runtimeErrorEvent.getErrorMessage()
        let errorCode = Int(runtimeErrorEvent.getErrorCode()) ?? 1
        let error = NSError(domain: errorDescription, code: errorCode)
        sendCompletionWithDelay(result: .failure(error))
        clear()
    }
}

// MARK: - Error

private extension TDSController {
    enum AppBasedControllerError: LocalizedError {
        case noPaymentSystem

        var errorDescription: String? {
            switch self {
            case .noPaymentSystem:
                return "Couldn't retrieve paymentSystem"
            }
        }
    }
}
