//
//  AddCardController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 16.02.2023.
//

import Foundation
import TinkoffASDKCore

struct AddingCardOptions {
    let pan: String
    let validThru: String
    let cvc: String
}

typealias AddCardCompletion = (AddCardStateResult) -> Void

enum AddCardStateResult {
    case succeded(GetAddCardStatePayload)
    case failed(Error)
    case cancelled
}

final class AddCardController {
    enum Error: Swift.Error {
        case missingPaymentId
        case unsupportedResponseStatus
    }

    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private let webFlowController: IThreeDSWebFlowController
    private let threeDSService: IAcquiringThreeDSService
    private let checkType: PaymentCardCheckType
    private let customerKey: String

    // MARK: Init

    init(
        coreSDK: AcquiringSdk,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider,
        webFlowController: IThreeDSWebFlowController,
        threeDSService: IAcquiringThreeDSService,
        customerKey: String,
        checkType: PaymentCardCheckType
    ) {
        self.coreSDK = coreSDK
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
        self.webFlowController = webFlowController
        self.threeDSService = threeDSService
        self.customerKey = customerKey
        self.checkType = checkType
    }
}

// MARK: - IAddCardController

extension AddCardController {
    var uiProvider: PaymentControllerUIProvider? {
        get { webFlowController.uiProvider }
        set { webFlowController.uiProvider = newValue }
    }

    func addCard(options: AddingCardOptions, completion: @escaping AddCardCompletion) {
        let completionDecorator: AddCardCompletion = { result in
            DispatchQueue.performOnMain { completion(result) }
        }

        let data = AddCardData(with: checkType, customerKey: customerKey)

        coreSDK.addCard(data: data) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.check3DSIfNeededAndAttachCard(payload: payload, options: options, completion: completionDecorator)
            case let .failure(error):
                completionDecorator(.failed(error))
            }
        }
    }
}

// MARK: - Helpers

extension AddCardController {
    private func check3DSIfNeededAndAttachCard(
        payload: AddCardPayload,
        options: AddingCardOptions,
        completion: @escaping AddCardCompletion
    ) {
        switch checkType {
        case .check3DS, .hold3DS:
            guard let paymentId = payload.paymentId else {
                return completion(.failed(Error.missingPaymentId))
            }

            check3DSVersionAndAttachCard(
                options: options,
                paymentId: paymentId,
                requestKey: payload.requestKey,
                completion: completion
            )
        case .no, .hold:
            attachCard(
                requestKey: payload.requestKey,
                options: options,
                completion: completion
            )
        }
    }

    private func check3DSVersionAndAttachCard(
        options: AddingCardOptions,
        paymentId: String,
        requestKey: String,
        completion: @escaping AddCardCompletion
    ) {
        coreSDK.check3DSVersion(data: .data(with: paymentId, options: options)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                if let tdsServerTransID = payload.tdsServerTransID,
                   let threeDSMethodURL = payload.threeDSMethodURL {

                    let checking3DSURLData = Checking3DSURLData(
                        tdsServerTransID: tdsServerTransID,
                        threeDSMethodURL: threeDSMethodURL,
                        notificationURL: self.threeDSService.confirmation3DSTerminationV2URL().absoluteString
                    )

                    self.complete3DSMethodAndAttachCard(
                        options: options,
                        checking3DSURLData: checking3DSURLData,
                        requestKey: requestKey,
                        messageVersion: payload.version,
                        completion: completion
                    )
                } else {
                    self.attachCard(
                        requestKey: requestKey,
                        options: options,
                        completion: completion
                    )
                }
            case let .failure(error):
                completion(.failed(error))
            }
        }
    }

    private func complete3DSMethodAndAttachCard(
        options: AddingCardOptions,
        checking3DSURLData: Checking3DSURLData,
        requestKey: String,
        messageVersion: String,
        completion: @escaping AddCardCompletion
    ) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            do {
                try self.webFlowController.complete3DSMethod(checking3DSURLData: checking3DSURLData)

                self.attachCard(
                    requestKey: requestKey,
                    options: options,
                    deviceData: self.threeDSDeviceInfoProvider.deviceInfo,
                    messageVersion: messageVersion,
                    completion: completion
                )
            } catch {
                completion(.failed(error))
            }
        }
    }

    private func attachCard(
        requestKey: String,
        options: AddingCardOptions,
        deviceData: ThreeDSDeviceInfo? = nil,
        messageVersion: String? = nil,
        completion: @escaping AddCardCompletion
    ) {
        let attachData = AttachCardData(
            cardNumber: options.pan,
            expDate: options.validThru,
            cvv: options.cvc,
            requestKey: requestKey,
            deviceData: deviceData
        )

        coreSDK.attachCard(data: attachData) { [weak self] result in
            switch result {
            case let .success(payload):
                self?.confirm3DSIfNeededAndGetState(payload: payload, messageVersion: messageVersion, completion: completion)
            case let .failure(error):
                completion(.failed(error))
            }
        }
    }

    private func confirm3DSIfNeededAndGetState(
        payload: AttachCardPayload,
        messageVersion: String?,
        completion: @escaping AddCardCompletion
    ) {
        switch payload.attachCardStatus {
        case let .needConfirmation3DS(confirmation3DSData):
            confirm3DS(confirmationData: confirmation3DSData, completion: completion)
        case let .needConfirmation3DSACS(confirmation3DSDataACS):
            confirm3DSACS(confirmationData: confirmation3DSDataACS, messageVersion: messageVersion ?? "2.1.0", completion: completion)
        case .done:
            getState(requestKey: payload.requestKey, completion: completion)
        case .needConfirmationRandomAmount:
            completion(.failed(Error.unsupportedResponseStatus))
        }
    }

    private func confirm3DS(confirmationData: Confirmation3DSData, completion: @escaping AddCardCompletion) {
        DispatchQueue.performOnMain { [weak self] in
            self?.webFlowController.confirm3DS(addCardConfirmationData: confirmationData) { webViewResult in
                self?.handle(webViewResult: webViewResult, completion: completion)
            }
        }
    }

    private func confirm3DSACS(
        confirmationData: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping AddCardCompletion
    ) {
        DispatchQueue.performOnMain { [weak self] in
            self?.webFlowController.confirm3DSACS(addCardConfirmationData: confirmationData, messageVersion: messageVersion) { webViewResult in
                self?.handle(webViewResult: webViewResult, completion: completion)
            }
        }
    }

    private func handle(
        webViewResult: ThreeDSWebViewHandlingResult<AddCardStatusResponse>,
        completion: @escaping AddCardCompletion
    ) {
        switch webViewResult {
        case .finished(payload: .success):
            break
        case let .finished(payload: .failure(error)):
            completion(.failed(error))
        case .cancelled:
            completion(.cancelled)
        }
    }

    private func getState(requestKey: String, completion: @escaping AddCardCompletion) {
        coreSDK.getAddCardState(data: GetAddCardStateData(requestKey: requestKey)) { result in
            switch result {
            case let .success(payload):
                completion(.succeded(payload))
            case let .failure(error):
                completion(.failed(error))
            }
        }
    }
}

// MARK: - Check3DSVersionData + Helpers

private extension Check3DSVersionData {
    static func data(with paymentId: String, options: AddingCardOptions) -> Check3DSVersionData {
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
