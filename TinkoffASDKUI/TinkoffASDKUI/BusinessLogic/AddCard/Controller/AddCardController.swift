//
//  AddCardController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 16.02.2023.
//

import Foundation
import TinkoffASDKCore

/// Объект, отвечающий за процесс привязки новой карты с прохождением проверки 3DS при необходимости
final class AddCardController {
    // MARK: Internal Types

    typealias Completion = (AddCardStateResult) -> Void

    enum Error: Swift.Error {
        case missingPaymentIdFor3DSFlow
        case missingMessageVersionFor3DS
        case unsupportedResponseStatus
        case invalidAttachStatus
    }

    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private let webFlowController: IThreeDSWebFlowController
    private let threeDSService: IAcquiringThreeDSService
    private let checkType: PaymentCardCheckType
    private let customerKey: String
    private let successfulStatuses: Set<AcquiringStatus>

    // MARK: Init

    init(
        coreSDK: AcquiringSdk,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider,
        webFlowController: IThreeDSWebFlowController,
        threeDSService: IAcquiringThreeDSService,
        customerKey: String,
        checkType: PaymentCardCheckType,
        successfulStatuses: Set<AcquiringStatus> = [.completed, .confirmed, .authorized]
    ) {
        self.coreSDK = coreSDK
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
        self.webFlowController = webFlowController
        self.threeDSService = threeDSService
        self.customerKey = customerKey
        self.checkType = checkType
        self.successfulStatuses = successfulStatuses
    }
}

// MARK: - IAddCardController

extension AddCardController: IAddCardController {
    var webFlowDelegate: ThreeDSWebFlowDelegate? {
        get { webFlowController.webFlowDelegate }
        set { webFlowController.webFlowDelegate = newValue }
    }

    func addCard(options: AddCardOptions, completion: @escaping (AddCardStateResult) -> Void) {
        let completionDecorator: Completion = { result in
            DispatchQueue.performOnMain { completion(result) }
        }

        coreSDK.addCard(data: AddCardData(with: checkType, customerKey: customerKey)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.check3DSVersionIfNeeded(
                    options: options,
                    addCardPayload: payload,
                    completion: completionDecorator
                )
            case let .failure(error):
                completionDecorator(.failed(error))
            }
        }
    }
}

// MARK: - Helpers

extension AddCardController {
    /// Выполняет проверку версии 3DS по необходимости, основываясь на заданном `checkType`
    private func check3DSVersionIfNeeded(
        options: AddCardOptions,
        addCardPayload: AddCardPayload,
        completion: @escaping Completion
    ) {
        switch checkType {
        case .check3DS, .hold3DS:
            guard let paymentId = addCardPayload.paymentId else {
                return completion(.failed(Error.missingPaymentIdFor3DSFlow))
            }

            check3DSVersion(
                options: options,
                paymentId: paymentId,
                requestKey: addCardPayload.requestKey,
                completion: completion
            )
        case .no, .hold:
            attachCard(
                requestKey: addCardPayload.requestKey,
                options: options,
                completion: completion
            )
        }
    }

    /// Выполняет проверку версии 3DS
    private func check3DSVersion(
        options: AddCardOptions,
        paymentId: String,
        requestKey: String,
        completion: @escaping Completion
    ) {
        coreSDK.check3DSVersion(data: .data(with: paymentId, options: options)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.complete3DSMethodIfNeededAndAttachCard(
                    options: options,
                    check3DSPayload: payload,
                    requestKey: requestKey,
                    completion: completion
                )
            case let .failure(error):
                completion(.failed(error))
            }
        }
    }

    /// Завершает подготовку к привязке карты при использовании `3DS v2`, а затем привязывает карту
    ///
    /// Параметры `tdsServerTransID`, `threeDSMethodURL` в `Check3DSVersionPayload` являются признаком проверки `3DS v2`
    private func complete3DSMethodIfNeededAndAttachCard(
        options: AddCardOptions,
        check3DSPayload: Check3DSVersionPayload,
        requestKey: String,
        completion: @escaping Completion
    ) {
        if let tdsServerTransID = check3DSPayload.tdsServerTransID,
           let threeDSMethodURL = check3DSPayload.threeDSMethodURL {

            let checking3DSURLData = Checking3DSURLData(
                tdsServerTransID: tdsServerTransID,
                threeDSMethodURL: threeDSMethodURL,
                notificationURL: threeDSService.confirmation3DSTerminationV2URL().absoluteString
            )

            complete3DSMethod(
                options: options,
                checking3DSURLData: checking3DSURLData,
                requestKey: requestKey,
                messageVersion: check3DSPayload.version,
                completion: completion
            )
        } else {
            attachCard(requestKey: requestKey, options: options, completion: completion)
        }
    }

    /// Завершает подготовку к привязке карты  с использованием `3DS v2`, а затем привязывает карту
    private func complete3DSMethod(
        options: AddCardOptions,
        checking3DSURLData: Checking3DSURLData,
        requestKey: String,
        messageVersion: String,
        completion: @escaping Completion
    ) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            do {
                try self.webFlowController.complete3DSMethod(checking3DSURLData: checking3DSURLData)
            } catch {
                return completion(.failed(error))
            }

            self.attachCard(
                requestKey: requestKey,
                options: options,
                deviceData: self.threeDSDeviceInfoProvider.deviceInfo,
                messageVersion: messageVersion,
                completion: completion
            )
        }
    }

    /// Привязывает карту
    private func attachCard(
        requestKey: String,
        options: AddCardOptions,
        deviceData: ThreeDSDeviceInfo? = nil,
        messageVersion: String? = nil,
        completion: @escaping Completion
    ) {
        let attachData = AttachCardData(
            cardNumber: options.pan,
            expDate: options.validThru,
            cvv: options.cvc,
            requestKey: requestKey,
            deviceData: deviceData
        )

        coreSDK.attachCard(data: attachData) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.confirm3DSIfNeeded(
                    attachCardPayload: payload,
                    messageVersion: messageVersion,
                    completion: completion
                )
            case let .failure(error):
                completion(.failed(error))
            }
        }
    }

    /// Подтверждает привязку карты с помощью `3DS` по необходимости, основываясь на ответе в `AttachCard`
    private func confirm3DSIfNeeded(
        attachCardPayload: AttachCardPayload,
        messageVersion: String?,
        completion: @escaping Completion
    ) {
        switch attachCardPayload.attachCardStatus {
        case let .needConfirmation3DS(confirmation3DSData):
            confirm3DS(confirmationData: confirmation3DSData, completion: completion)
        case let .needConfirmation3DSACS(confirmation3DSDataACS):
            guard let messageVersion = messageVersion else {
                return completion(.failed(Error.missingMessageVersionFor3DS))
            }

            confirm3DSACS(
                confirmationData: confirmation3DSDataACS,
                messageVersion: messageVersion,
                completion: completion
            )
        case .done:
            getState(requestKey: attachCardPayload.requestKey, completion: completion)
        case .needConfirmationRandomAmount:
            completion(.failed(Error.unsupportedResponseStatus))
        }
    }

    /// Подтверждает привязку карты с помощью `Web Flow 3DS v1`
    private func confirm3DS(confirmationData: Confirmation3DSData, completion: @escaping Completion) {
        DispatchQueue.performOnMain { [weak self] in
            self?.webFlowController.confirm3DS(addCardConfirmationData: confirmationData) { webViewResult in
                self?.handle(webViewResult: webViewResult, completion: completion)
            }
        }
    }

    /// Подтверждает привязку карты с помощью `Web Flow 3DS v2`
    private func confirm3DSACS(
        confirmationData: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping Completion
    ) {
        DispatchQueue.performOnMain { [weak self] in
            self?.webFlowController.confirm3DSACS(
                addCardConfirmationData: confirmationData,
                messageVersion: messageVersion
            ) { webViewResult in
                self?.handle(webViewResult: webViewResult, completion: completion)
            }
        }
    }

    /// Обрабатывает результат работы `3DS WebView`
    private func handle(
        webViewResult: ThreeDSWebViewHandlingResult<GetAddCardStatePayload>,
        completion: @escaping Completion
    ) {
        switch webViewResult {
        case let .succeded(payload):
            validate(statePayload: payload, completion: completion)
        case let .failed(error):
            completion(.failed(error))
        case .cancelled:
            completion(.cancelled)
        }
    }

    /// Запрашивает статус привзяки карты
    private func getState(requestKey: String, completion: @escaping Completion) {
        coreSDK.getAddCardState(data: GetAddCardStateData(requestKey: requestKey)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.validate(statePayload: payload, completion: completion)
            case let .failure(error):
                completion(.failed(error))
            }
        }
    }

    /// Валидирует статус привязки карты. При неуспешном статусе возвращает ошибку
    private func validate(statePayload: GetAddCardStatePayload, completion: @escaping Completion) {
        guard successfulStatuses.contains(statePayload.status) else {
            return completion(.failed(Error.invalidAttachStatus))
        }

        completion(.succeded(statePayload))
    }
}

// MARK: - Check3DSVersionData + Helpers

private extension Check3DSVersionData {
    static func data(with paymentId: String, options: AddCardOptions) -> Check3DSVersionData {
        Check3DSVersionData(
            paymentId: paymentId,
            paymentSource: .cardNumber(
                number: options.pan,
                expDate: options.validThru,
                cvv: options.cvc
            )
        )
    }
}
