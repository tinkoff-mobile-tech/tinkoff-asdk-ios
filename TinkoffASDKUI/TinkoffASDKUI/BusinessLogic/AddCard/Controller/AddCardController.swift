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
        case invalidPaymentStatus(AcquiringStatus)
        case invalidCardStatus(AcquiringStatus)
    }

    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private let webFlowController: IThreeDSWebFlowController
    private let threeDSService: IAcquiringThreeDSService
    private let checkType: PaymentCardCheckType
    private let customerKey: String
    private let cardStateSuccessfulStatuses: Set<AcquiringStatus>
    private let paymentStateSuccessfulStatuses: Set<AcquiringStatus>

    // MARK: Init

    init(
        coreSDK: AcquiringSdk,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider,
        webFlowController: IThreeDSWebFlowController,
        threeDSService: IAcquiringThreeDSService,
        customerKey: String,
        checkType: PaymentCardCheckType,
        successfulStatuses: Set<AcquiringStatus> = [.completed],
        paymentStateSuccessfulStatuses: Set<AcquiringStatus> = [.authorized, .confirmed]
    ) {
        self.coreSDK = coreSDK
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
        self.webFlowController = webFlowController
        self.threeDSService = threeDSService
        self.customerKey = customerKey
        self.checkType = checkType
        cardStateSuccessfulStatuses = successfulStatuses
        self.paymentStateSuccessfulStatuses = paymentStateSuccessfulStatuses
    }
}

// MARK: - IAddCardController

extension AddCardController: IAddCardController {
    var webFlowDelegate: ThreeDSWebFlowDelegate? {
        get { webFlowController.webFlowDelegate }
        set { webFlowController.webFlowDelegate = newValue }
    }

    func addCard(options: CardOptions, completion: @escaping (AddCardStateResult) -> Void) {
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
        options: CardOptions,
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
        options: CardOptions,
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
        options: CardOptions,
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
        options: CardOptions,
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
        options: CardOptions,
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
                    attachPayload: payload,
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
        attachPayload: AttachCardPayload,
        messageVersion: String?,
        completion: @escaping Completion
    ) {
        switch attachPayload.attachCardStatus {
        case let .needConfirmation3DS(confirmation3DSData):
            confirm3DS(
                confirmationData: confirmation3DSData,
                attachPayload: attachPayload,
                completion: completion
            )
        case let .needConfirmation3DSACS(confirmation3DSDataACS):
            guard let messageVersion = messageVersion else {
                return completion(.failed(Error.missingMessageVersionFor3DS))
            }

            confirm3DSACS(
                confirmationData: confirmation3DSDataACS,
                messageVersion: messageVersion,
                attachPayload: attachPayload,
                completion: completion
            )
        case .done:
            getState(
                attachPayload: attachPayload,
                completion: completion
            )
        case .needConfirmationRandomAmount:
            completion(.failed(Error.unsupportedResponseStatus))
        }
    }

    /// Подтверждает привязку карты с помощью `Web Flow 3DS v1`
    private func confirm3DS(
        confirmationData: Confirmation3DSData,
        attachPayload: AttachCardPayload,
        completion: @escaping Completion
    ) {
        DispatchQueue.performOnMain { [weak self] in
            self?.webFlowController.confirm3DS(data: confirmationData) { webViewResult in
                self?.validate(
                    webViewResult: webViewResult,
                    attachPayload: attachPayload,
                    completion: completion
                )
            }
        }
    }

    /// Подтверждает привязку карты с помощью `Web Flow 3DS v2`
    private func confirm3DSACS(
        confirmationData: Confirmation3DSDataACS,
        messageVersion: String,
        attachPayload: AttachCardPayload,
        completion: @escaping Completion
    ) {
        DispatchQueue.performOnMain { [weak self] in
            self?.webFlowController.confirm3DSACS(data: confirmationData, messageVersion: messageVersion) { webViewResult in
                self?.validate(
                    webViewResult: webViewResult,
                    attachPayload: attachPayload,
                    completion: completion
                )
            }
        }
    }

    /// Валидирует результат работы `3DS WebView`. При неуспешном ответе возвращает ошибку
    private func validate(
        webViewResult: ThreeDSWebViewHandlingResult<GetPaymentStatePayload>,
        attachPayload: AttachCardPayload,
        completion: @escaping Completion
    ) {
        switch webViewResult {
        case let .succeded(payload) where paymentStateSuccessfulStatuses.contains(payload.status):
            getState(attachPayload: attachPayload, completion: completion)
        case let .succeded(payload):
            completion(.failed(Error.invalidPaymentStatus(payload.status)))
        case let .failed(error):
            completion(.failed(error))
        case .cancelled:
            completion(.cancelled)
        }
    }

    /// Запрашивает статус привзяки карты
    private func getState(attachPayload: AttachCardPayload, completion: @escaping Completion) {
        let getStateData = GetAddCardStateData(requestKey: attachPayload.requestKey)

        coreSDK.getAddCardState(data: getStateData) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                let payload = payload.replacingIfNeeded(cardId: attachPayload.cardId, rebillId: attachPayload.rebillId)
                self.validate(statePayload: payload, completion: completion)
            case let .failure(error):
                completion(.failed(error))
            }
        }
    }

    /// Валидирует статус привязки карты. При неуспешном статусе возвращает ошибку
    private func validate(statePayload: GetAddCardStatePayload, completion: @escaping Completion) {
        guard cardStateSuccessfulStatuses.contains(statePayload.status) else {
            return completion(.failed(Error.invalidCardStatus(statePayload.status)))
        }

        completion(.succeded(statePayload))
    }
}

// MARK: - AddCardController.Error + LocalizedError

extension AddCardController.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingPaymentIdFor3DSFlow:
            return "Unexpected nil for `paymentId` in `AddCard` response when using 3DS Flow"
        case .missingMessageVersionFor3DS:
            return "Unexpected nil for `messageVersion` when using 3DS v2 Flow"
        case .unsupportedResponseStatus:
            return "`LOOP_CHECKING` status is deprecated and not handling in Acquiring SDK"
        case let .invalidPaymentStatus(status):
            return "Something went wrong when withdrawing money from the card. \(status.rawValue) isn't valid final payment status"
        case let .invalidCardStatus(status):
            return "Something went wrong when attaching card. \(status.rawValue) isn't valid final card status"
        }
    }
}

// MARK: - Check3DSVersionData + Helpers

private extension Check3DSVersionData {
    static func data(with paymentId: String, options: CardOptions) -> Check3DSVersionData {
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

private extension GetAddCardStatePayload {
    /// Заменяет `cardId` и `rebillId` переданными значениями, если собственные параметры отсутствуют
    ///
    /// При привязке карты без использования 3DS  эти параметры не возвращаются в запросе `GetAddCardState`,
    /// но зато они присутствуют в запросе `AttachCard`. При использовании 3DS все в точности наоборот.
    /// Этот небольшой костыль лечит отсутствие нужных параметров в completion `AddCardController`
    func replacingIfNeeded(cardId: String?, rebillId: String?) -> GetAddCardStatePayload {
        GetAddCardStatePayload(
            requestKey: requestKey,
            status: status,
            cardId: self.cardId ?? cardId,
            rebillId: self.rebillId ?? rebillId
        )
    }
}
