//
//
//  PaymentController.swift
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

import Foundation
import TinkoffASDKCore
import UIKit

final class PaymentController: IPaymentController {
    // MARK: IPaymentController Properties

    weak var delegate: PaymentControllerDelegate?

    var webFlowDelegate: (any ThreeDSWebFlowDelegate)? {
        get { threeDSWebFlowController.webFlowDelegate }
        set { threeDSWebFlowController.webFlowDelegate = newValue }
    }

    // MARK: Dependencies

    private let threeDSService: IAcquiringThreeDSService
    private let paymentFactory: IPaymentFactory
    private let threeDSWebFlowController: IThreeDSWebFlowController
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private let tdsController: ITDSController
    private let paymentStatusUpdateService: IPaymentStatusUpdateService

    // MARK: State

    private var paymentProcess: IPaymentProcess?

    // MARK: Init

    init(
        paymentFactory: IPaymentFactory,
        threeDSWebFlowController: IThreeDSWebFlowController,
        threeDSService: IAcquiringThreeDSService,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider,
        tdsController: ITDSController,
        paymentStatusUpdateService: IPaymentStatusUpdateService
    ) {
        self.threeDSService = threeDSService
        self.paymentFactory = paymentFactory
        self.threeDSWebFlowController = threeDSWebFlowController
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
        self.tdsController = tdsController
        self.paymentStatusUpdateService = paymentStatusUpdateService

        paymentStatusUpdateService.delegate = self
    }

    deinit {
        paymentProcess?.cancel()
        paymentProcess = nil
    }

    // MARK: IPaymentController

    func performPayment(paymentFlow: PaymentFlow, paymentSource: PaymentSourceData) {
        paymentProcess?.cancel()

        paymentProcess = paymentFactory.createPayment(
            paymentSource: paymentSource,
            paymentFlow: paymentFlow,
            paymentDelegate: self
        )

        paymentProcess?.start()
    }
}

// MARK: PaymentProcessDelegate

extension PaymentController: PaymentProcessDelegate {
    func paymentDidFinish(
        _ paymentProcess: IPaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }
            self.paymentProcess = nil
            self.tdsController.stop()

            let data = FullPaymentData(paymentProcess: paymentProcess, payload: state, cardId: cardId, rebillId: rebillId)
            self.paymentStatusUpdateService.startUpdateStatusIfNeeded(data: data)
        }
    }

    func paymentDidFailed(
        _ paymentProcess: IPaymentProcess,
        with error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }
            self.paymentProcess = nil
            self.tdsController.stop()

            guard !self.intercept(error: error, paymentProcess: paymentProcess, rebillId: rebillId) else { return }

            self.delegate?.paymentController(
                self,
                didFailed: error,
                cardId: cardId,
                rebillId: rebillId
            )
        }
    }

    func payment(
        _ paymentProcess: IPaymentProcess,
        needToCollect3DSData checking3DSURLData: Checking3DSURLData,
        completion: @escaping (ThreeDSDeviceInfo) -> Void
    ) {

        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            try? self.threeDSWebFlowController.complete3DSMethod(checking3DSURLData: checking3DSURLData)
            completion(self.threeDSDeviceInfoProvider.deviceInfo)
        }
    }

    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmation data: Confirmation3DSData,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.threeDSWebFlowController.confirm3DS(data: data) { webViewResult in
                self.handle(
                    webViewResult: webViewResult,
                    onCancel: confirmationCancelled,
                    completion: completion
                )
            }
        }
    }

    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmationACS data: Confirmation3DSDataACS,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.threeDSWebFlowController.confirm3DSACS(data: data, messageVersion: version) { webViewResult in
                self.handle(
                    webViewResult: webViewResult,
                    onCancel: confirmationCancelled,
                    completion: completion
                )
            }
        }
    }

    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmationAppBased data: Confirmation3DS2AppBasedData,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        tdsController.completionHandler = completion
        tdsController.cancelHandler = confirmationCancelled
        tdsController.doChallenge(with: data)
    }

    func startAppBasedFlow(
        check3dsPayload: Check3DSVersionPayload,
        completion: @escaping (Result<ThreeDSDeviceInfo, Error>) -> Void
    ) {
        tdsController.startAppBasedFlow(
            check3dsPayload: check3dsPayload,
            completion: completion
        )
    }
}

// MARK: - IPaymentStatusUpdateServiceDelegate

extension PaymentController: IPaymentStatusUpdateServiceDelegate {
    func paymentFinalStatusRecieved(data: FullPaymentData) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.delegate?.paymentController(
                self,
                didFinishPayment: data.paymentProcess,
                with: data.payload,
                cardId: data.cardId,
                rebillId: data.rebillId
            )
        }
    }

    func paymentCancelStatusRecieved(data: FullPaymentData) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.delegate?.paymentController(
                self,
                paymentWasCancelled: data.paymentProcess,
                cardId: data.cardId,
                rebillId: data.rebillId
            )
        }
    }

    func paymentFailureStatusRecieved(data: FullPaymentData, error: Error) {
        paymentDidFailed(data.paymentProcess, with: error, cardId: data.cardId, rebillId: data.rebillId)
    }
}

// MARK: - Helpers

extension PaymentController {
    private func handle(
        webViewResult: ThreeDSWebViewHandlingResult<GetPaymentStatePayload>,
        onCancel: @escaping VoidBlock,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        switch webViewResult {
        case let .succeded(payload):
            completion(.success(payload))
        case let .failed(error):
            completion(.failure(error))
        case .cancelled:
            paymentProcess?.cancel()
            onCancel()
        }
    }

    private func intercept(
        error: Error,
        paymentProcess: IPaymentProcess,
        rebillId: String?
    ) -> Bool {
        guard let rebillId = rebillId,
              let chargeDelegate = delegate as? ChargePaymentControllerDelegate,
              let failedPaymentId = paymentProcess.paymentId else {
            return false
        }

        let additionalData = ["failMapiSessionId": "\(failedPaymentId)", "recurringType": "12"]

        let errorCode = (error as NSError).code
        switch errorCode {
        case 104:
            chargeDelegate.paymentController(
                self,
                shouldRepeatWithRebillId: rebillId,
                failedPaymentProcess: paymentProcess,
                additionalData: additionalData,
                error: error
            )
            return true
        default:
            return false
        }
    }
}
