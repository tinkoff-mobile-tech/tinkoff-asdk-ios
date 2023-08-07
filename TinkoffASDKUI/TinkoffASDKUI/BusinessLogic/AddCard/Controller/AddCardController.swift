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
        case invalidPaymentStatus(AcquiringStatus)
        case invalidCardStatus(AcquiringStatus)
    }

    // MARK: IAddCardController Properties

    let customerKey: String
    private let addCardOptions: AddCardOptions

    // MARK: Dependencies

    private let addCardService: IAddCardService
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private let webFlowController: IThreeDSWebFlowController
    private let threeDSService: IAcquiringThreeDSService
    private let checkType: PaymentCardCheckType
    private let cardStateSuccessfulStatuses: Set<AcquiringStatus>
    private let paymentStateSuccessfulStatuses: Set<AcquiringStatus>
    private let tdsController: ITDSController

    // MARK: Init

    init(
        addCardService: IAddCardService,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider,
        webFlowController: IThreeDSWebFlowController,
        threeDSService: IAcquiringThreeDSService,
        customerKey: String,
        addCardOptions: AddCardOptions,
        checkType: PaymentCardCheckType,
        tdsController: ITDSController,
        successfulStatuses: Set<AcquiringStatus> = [.completed],
        paymentStateSuccessfulStatuses: Set<AcquiringStatus> = [.authorized, .confirmed]
    ) {
        self.addCardService = addCardService
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
        self.webFlowController = webFlowController
        self.threeDSService = threeDSService
        self.customerKey = customerKey
        self.addCardOptions = addCardOptions
        self.checkType = checkType
        self.tdsController = tdsController
        cardStateSuccessfulStatuses = successfulStatuses
        self.paymentStateSuccessfulStatuses = paymentStateSuccessfulStatuses
    }
}

// MARK: - IAddCardController

extension AddCardController: IAddCardController {
    var webFlowDelegate: (any ThreeDSWebFlowDelegate)? {
        get { webFlowController.webFlowDelegate }
        set { webFlowController.webFlowDelegate = newValue }
    }

    func addCard(cardData: CardData, completion: @escaping (AddCardStateResult) -> Void) {
        let completionDecorator: Completion = { result in
            DispatchQueue.performOnMain { completion(result) }
        }

        addCardService.addCard(data: AddCardData(with: checkType, customerKey: customerKey)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.check3DSVersionIfNeeded(
                    cardData: cardData,
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
        cardData: CardData,
        addCardPayload: AddCardPayload,
        completion: @escaping Completion
    ) {
        switch checkType {
        case .check3DS, .hold3DS:
            guard let paymentId = addCardPayload.paymentId else {
                return completion(.failed(Error.missingPaymentIdFor3DSFlow))
            }

            check3DSVersion(
                cardData: cardData,
                paymentId: paymentId,
                requestKey: addCardPayload.requestKey,
                completion: completion
            )
        case .no, .hold:
            attachCard(
                requestKey: addCardPayload.requestKey,
                cardData: cardData,
                data: .dictionary(addCardOptions.attachCardData ?? .empty()),
                completion: completion
            )
        }
    }

    /// Выполняет проверку версии 3DS
    private func check3DSVersion(
        cardData: CardData,
        paymentId: String,
        requestKey: String,
        completion: @escaping Completion
    ) {
        addCardService.check3DSVersion(data: .data(with: paymentId, cardData: cardData)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.complete3DSMethodIfNeededAndAttachCard(
                    cardData: cardData,
                    addCardOptions: self.addCardOptions,
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
        cardData: CardData,
        addCardOptions: AddCardOptions,
        check3DSPayload: Check3DSVersionPayload,
        requestKey: String,
        completion: @escaping Completion
    ) {
        switch check3DSPayload.receiveVersion() {
        case .v1:
            attachCard(
                requestKey: requestKey,
                cardData: cardData,
                data: .dictionary(addCardOptions.attachCardData ?? .empty()),
                completion: completion
            )

        // TODO: EACQAPW-5432 ждет задачу чтобы убрать appBased из case
        case .v2, .appBased:
            guard let tdsServerTransID = check3DSPayload.tdsServerTransID,
                  let threeDSMethodURL = check3DSPayload.threeDSMethodURL
            else { return }

            let checking3DSURLData = Checking3DSURLData(
                tdsServerTransID: tdsServerTransID,
                threeDSMethodURL: threeDSMethodURL,
                notificationURL: threeDSService.confirmation3DSTerminationV2URL().absoluteString
            )

            complete3DSMethod(
                cardData: cardData,
                addCardOptions: addCardOptions,
                checking3DSURLData: checking3DSURLData,
                requestKey: requestKey,
                messageVersion: check3DSPayload.version,
                completion: completion
            )

            // TODO: EACQAPW-5432 ждет задачу а именно доработки МАПИ
            // Интеграция 3ds-app-based flow [флоу привязки карты]

            /*
             case .appBased:
                 tdsController.startAppBasedFlow(
                     check3dsPayload: check3DSPayload,
                     completion: { [weak self] result in
                         guard let self = self else { return }
                         switch result {
                         case let .success(deviceInfo):
                             self.attachCard(
                                 requestKey: requestKey,
                                 options: options,
                                 deviceData: deviceInfo,
                                 messageVersion: check3DSPayload.version,
                                 completion: completion
                             )
                         case let .failure(error):
                             completion(.failed(error))
                         }
                     }
                 )
             */
        }
    }

    /// Завершает подготовку к привязке карты  с использованием `3DS v2`, а затем привязывает карту
    private func complete3DSMethod(
        cardData: CardData,
        addCardOptions: AddCardOptions,
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

            let browserData = self.threeDSDeviceInfoProvider.createThreeDsDataBrowser()
            let data = FinishAuthorizeDataWrapper<ThreeDsDataBrowser>(
                data: browserData,
                additionalData: addCardOptions.attachCardData
            )

            self.attachCard(
                requestKey: requestKey,
                cardData: cardData,
                data: .threeDsBrowser(data),
                messageVersion: messageVersion,
                completion: completion
            )
        }
    }

    /// Привязывает карту
    private func attachCard(
        requestKey: String,
        cardData: CardData,
        data: FinishAuthorizeDataEnum?,
        messageVersion: String? = nil,
        completion: @escaping Completion
    ) {
        let attachData = AttachCardData(
            cardNumber: cardData.pan,
            expDate: cardData.validThru,
            cvv: cardData.cvc,
            requestKey: requestKey,
            data: data
        )

        addCardService.attachCard(data: attachData) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.confirm3DSIfNeeded(
                    attachPayload: payload,
                    messageVersion: messageVersion,
                    completion: completion
                )
            case let .failure(error):
                self.tdsController.stop()
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
        case let .needConfirmation3DS2AppBased(confirmationAppBasedData):
            guard let messageVersion = messageVersion else {
                return completion(.failed(Error.missingMessageVersionFor3DS))
            }
            confirm3DSAppBased(
                confirmationData: confirmationAppBasedData,
                messageVersion: messageVersion,
                attachPayload: attachPayload,
                completion: completion
            )

        case .done:
            getState(
                attachPayload: attachPayload,
                completion: completion
            )
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

    /// Подтверждает привязку карты с помощью `App Based 3DS v2`
    private func confirm3DSAppBased(
        confirmationData: Confirmation3DS2AppBasedData,
        messageVersion: String,
        attachPayload: AttachCardPayload,
        completion: @escaping Completion
    ) {
        DispatchQueue.performOnMain { [weak self] in
            self?.tdsController.cancelHandler = {
                completion(.cancelled)
            }

            self?.tdsController.completionHandler = { result in
                print(try? result.get())
                fatalError()
            }

            self?.tdsController.doChallenge(with: confirmationData)
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

        addCardService.getAddCardState(data: getStateData) { [weak self] result in
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
        case let .invalidPaymentStatus(status):
            return "Something went wrong when withdrawing money from the card. \(status.rawValue) isn't valid final payment status"
        case let .invalidCardStatus(status):
            return "Something went wrong when attaching card. \(status.rawValue) isn't valid final card status"
        }
    }
}

// MARK: - Check3DSVersionData + Helpers

private extension Check3DSVersionData {
    static func data(with paymentId: String, cardData: CardData) -> Check3DSVersionData {
        Check3DSVersionData(
            paymentId: paymentId,
            paymentSource: .cardNumber(
                number: cardData.pan,
                expDate: cardData.validThru,
                cvv: cardData.cvc
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
