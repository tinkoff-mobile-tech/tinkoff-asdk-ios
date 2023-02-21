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
    weak var dataSource: PaymentControllerDataSource?

    var webFlowDelegate: ThreeDSWebFlowDelegate? {
        get { threeDSWebFlowController.webFlowDelegate }
        set { threeDSWebFlowController.webFlowDelegate = newValue }
    }

    // MARK: Dependencies

    private let threeDSService: IAcquiringThreeDSService
    private let paymentFactory: IPaymentFactory
    private let threeDSWebFlowController: IThreeDSWebFlowController
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private let tdsController: TDSController
    private let paymentStatusUpdateService: IPaymentStatusUpdateService

    // MARK: Temporary until refactor PaymentView!

    private let acquiringUISDK: AcquiringUISDK

    // MARK: State

    private var paymentProcess: PaymentProcess?

    // MARK: Init

    init(
        paymentFactory: PaymentFactory,
        threeDSWebFlowController: IThreeDSWebFlowController,
        threeDSService: IAcquiringThreeDSService,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider,
        tdsController: TDSController,
        paymentStatusUpdateService: IPaymentStatusUpdateService,
        acquiringUISDK: AcquiringUISDK /* temporary*/
    ) {
        self.threeDSService = threeDSService
        self.paymentFactory = paymentFactory
        self.threeDSWebFlowController = threeDSWebFlowController
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
        self.tdsController = tdsController
        self.paymentStatusUpdateService = paymentStatusUpdateService
        self.acquiringUISDK = acquiringUISDK

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
        _ paymentProcess: PaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }
            self.paymentProcess = nil

            let data = FullPaymentData(paymentProcess: paymentProcess, payload: state, cardId: cardId, rebillId: rebillId)
            self.paymentStatusUpdateService.startUpdateStatusIfNeeded(data: data)
        }
    }

    func paymentDidFailed(
        _ paymentProcess: PaymentProcess,
        with error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }
            self.paymentProcess = nil

            guard !self.interceptError(error, for: paymentProcess) else { return }

            self.delegate?.paymentController(
                self,
                didFailed: error,
                cardId: cardId,
                rebillId: rebillId
            )
        }
    }

    func payment(
        _ paymentProcess: PaymentProcess,
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
        _ paymentProcess: PaymentProcess,
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
        _ paymentProcess: PaymentProcess,
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
        _ paymentProcess: PaymentProcess,
        need3DSConfirmationAppBased data: Confirmation3DS2AppBasedData,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        tdsController.completionHandler = { response in
            let mappedResponse = response.map { statusResponse in
                GetPaymentStatePayload(
                    paymentId: String(statusResponse.paymentId),
                    amount: Int64(truncating: statusResponse.amount),
                    orderId: statusResponse.orderId,
                    status: statusResponse.status
                )
            }

            completion(mappedResponse)
        }

        tdsController.cancelHandler = confirmationCancelled
        tdsController.doChallenge(with: data)
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

    private func interceptError(_ error: Error, for paymentProcess: PaymentProcess) -> Bool {
        let errorCode = (error as NSError).code
        switch errorCode {
        case 104:
            return handleChargeRequireCVCInput(paymentProcess: paymentProcess)
        default:
            return false
        }
    }

    private func handleChargeRequireCVCInput(paymentProcess: PaymentProcess) -> Bool {
        guard let sourceViewController = webFlowDelegate?.sourceViewControllerToPresent(),
              let chargePaymentDataSource = dataSource as? ChargePaymentControllerDataSource else {
            return false
        }

        let viewConfiguration = chargePaymentDataSource.paymentController(self, viewConfigurationToRetry: paymentProcess)

        let customerKey: String?
        let paymentOptions: PaymentOptions?
        let parentPaymentId: String?

        switch paymentProcess.paymentFlow {
        case let .full(processPaymentOptions):
            paymentOptions = processPaymentOptions
            customerKey = getCustomerKey(for: paymentProcess, customerOptions: processPaymentOptions.customerOptions)
        case let .finish(_, customerOptions):
            paymentOptions = (dataSource as? ChargePaymentControllerDataSource)?.paymentController(self, paymentOptionsToRetry: paymentProcess)
            customerKey = getCustomerKey(for: paymentProcess, customerOptions: customerOptions)
        }

        switch paymentProcess.paymentSource {
        case let .parentPayment(rebillId):
            parentPaymentId = rebillId
        default:
            return false
        }

        guard let repeatCustomerKey = customerKey,
              let repeatPaymentOptions = paymentOptions,
              let repeatParentPaymentId = parentPaymentId else {
            return false
        }

        repeatChargeWithCVCInput(
            paymentOptions: repeatPaymentOptions,
            sourceViewController: sourceViewController,
            viewConfiguration: viewConfiguration,
            customerKey: repeatCustomerKey,
            parentPaymentId: repeatParentPaymentId,
            failedPaymentId: paymentProcess.paymentId
        )
        return true
    }

    private func getCustomerKey(for paymentProcess: PaymentProcess, customerOptions: CustomerOptions?) -> String? {
        let customerKey: String?
        if let key = customerOptions?.customerKey {
            customerKey = key
        } else if let dataSourceKey = (dataSource as? ChargePaymentControllerDataSource)?
            .paymentController(self, customerKeyToRetry: paymentProcess) {
            customerKey = dataSourceKey
        } else {
            customerKey = nil
        }
        return customerKey
    }

    private func repeatChargeWithCVCInput(
        paymentOptions: PaymentOptions,
        sourceViewController: UIViewController,
        viewConfiguration: AcquiringViewConfiguration,
        customerKey: String,
        parentPaymentId: String,
        failedPaymentId: String?
    ) {
        let newOrderOptions = OrderOptions(
            orderId: paymentOptions.orderOptions.orderId,
            amount: paymentOptions.orderOptions.amount,
            description: paymentOptions.orderOptions.description,
            receipt: paymentOptions.orderOptions.receipt,
            shops: paymentOptions.orderOptions.shops,
            receipts: paymentOptions.orderOptions.receipts,
            savingAsParentPayment: true
        )
        let newPaymentOptions = PaymentOptions(
            orderOptions: newOrderOptions,
            customerOptions: paymentOptions.customerOptions,
            failedPaymentId: failedPaymentId
        )

        // Temporary until refactor PaymentView! Remove ASAP!

        acquiringUISDK.setupCardListDataProvider(for: customerKey)

        acquiringUISDK.presentAcquiringPaymentView(
            presentingViewController: sourceViewController,
            customerKey: customerKey,
            configuration: viewConfiguration,
            onPresenting: { acquiringView in
                acquiringView.changedStatus(.initWaiting)
                acquiringView.changedStatus(.paymentWainingCVC(cardParentId: Int64(parentPaymentId) ?? 0))

                acquiringView.onTouchButtonPay = { [weak self, weak acquiringView] in
                    guard let cardRequisites = acquiringView?.cardRequisites() else { return }
                    self?.performInitPayment(paymentOptions: newPaymentOptions, paymentSource: cardRequisites)
                }
            }
        )
    }
}
