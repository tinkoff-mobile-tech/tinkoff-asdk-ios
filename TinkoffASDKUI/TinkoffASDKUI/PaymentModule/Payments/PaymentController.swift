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

import TinkoffASDKCore
import WebKit

protocol IPaymentController {
    func performPayment(paymentFlow: PaymentFlow, paymentSource: PaymentSourceData)
    func performInitPayment(paymentOptions: PaymentOptions, paymentSource: PaymentSourceData)
    func performFinishPayment(paymentId: String, paymentSource: PaymentSourceData, customerOptions: CustomerOptions?)
}

/// Объект, предоставляющий для `PaymentController` UI-компоненты для совершения платежа
public protocol PaymentControllerUIProvider: AnyObject {
    /// webView, в котором выполнится запрос для прохождения 3DSChecking
    func hiddenWebViewToCollect3DSData() -> WKWebView
    /// viewController для модального показа экранов, необходимость в которых может возникнуть в процессе оплаты
    func sourceViewControllerToPresent() -> UIViewController?
}

/// Делегат событий для `PaymentController`
public protocol PaymentControllerDelegate: AnyObject {
    /// Оплата прошла успешно
    func paymentController(
        _ controller: PaymentController,
        didFinishPayment paymentProcess: PaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    )

    /// Оплата была отменена
    func paymentController(
        _ controller: PaymentController,
        paymentWasCancelled paymentProcess: PaymentProcess,
        cardId: String?,
        rebillId: String?
    )

    /// Возникла ошибка в процессе оплаты
    func paymentController(
        _ controller: PaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    )
}

/// Объект, предоставляющий дополнительный данные для `PaymentController`
public protocol PaymentControllerDataSource: AnyObject {}

/// Объект, предоставляющий дополнительный данные для `PaymentController` в случае, если запрос `Charge` вернул ошибку `104`
public protocol ChargePaymentControllerDataSource: PaymentControllerDataSource {
    /// `AcquiringViewConfiguration` для отображения экрана оплаты с возможность ввести `CVC`
    func paymentController(
        _ controller: PaymentController,
        viewConfigurationToRetry paymentProcess: PaymentProcess
    ) -> AcquiringViewConfiguration
    /// вызовется, если при инициации оплаты с `PaymentSourceData.parentPayment` не был предоставлен `CustomerKey` в `CustomerOptions`
    func paymentController(
        _ controller: PaymentController,
        customerKeyToRetry chargePaymentProcess: PaymentProcess
    ) -> String?
    /// вызовется, если оплата была была инициирована через метод `performFinishPayment`
    func paymentController(
        _ controller: PaymentController,
        paymentOptionsToRetry chargePaymentProcess: PaymentProcess
    ) -> PaymentOptions?
}

public extension ChargePaymentControllerDataSource {
    func paymentController(
        _ controller: PaymentController,
        customerKeyToRetry chargePaymentProcess: PaymentProcess
    ) -> String? { return nil }
    func paymentController(
        _ controller: PaymentController,
        paymentOptionsToRetry chargePaymentProcess: PaymentProcess
    ) -> PaymentOptions? { return nil }
}

/// Контроллер с помощью которого можно совершать оплату
public final class PaymentController: IPaymentController {

    // MARK: - Dependencies

    var uiProvider: PaymentControllerUIProvider? {
        get { threeDSWebFlowController.uiProvider }
        set { threeDSWebFlowController.uiProvider = newValue }
    }

    weak var delegate: PaymentControllerDelegate?
    weak var dataSource: PaymentControllerDataSource?

    private let threeDSService: IAcquiringThreeDSService
    private let paymentFactory: IPaymentFactory
    private let threeDSWebFlowController: IThreeDSWebFlowController
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private let tdsController: TDSController
    private let paymentStatusUpdateService: IPaymentStatusUpdateService

    // MARK: - State

    private var paymentProcess: PaymentProcess?

    // MARK: - Temporary until refactor PaymentView!

    private let acquiringUISDK: AcquiringUISDK

    // MARK: - Init

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

    // MARK: - Payments

    public func performPayment(paymentFlow: PaymentFlow, paymentSource: PaymentSourceData) {
        paymentProcess?.cancel()

        paymentProcess = paymentFactory.createPayment(
            paymentSource: paymentSource,
            paymentFlow: paymentFlow,
            paymentDelegate: self
        )

        paymentProcess?.start()
    }

    public func performInitPayment(paymentOptions: PaymentOptions, paymentSource: PaymentSourceData) {
        performPayment(paymentFlow: .full(paymentOptions: paymentOptions), paymentSource: paymentSource)
    }

    public func performFinishPayment(
        paymentId: String,
        paymentSource: PaymentSourceData,
        customerOptions: CustomerOptions?
    ) {
        performPayment(
            paymentFlow: .finish(paymentId: paymentId, customerOptions: customerOptions),
            paymentSource: paymentSource
        )
    }
}

// MARK: - PaymentProcessDelegate

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

    func payment(
        _ paymentProcess: PaymentProcess,
        need3DSConfirmation data: Confirmation3DSData,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.threeDSWebFlowController.confirm3DS(paymentConfirmationData: data) { webViewResult in
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

            self.threeDSWebFlowController.confirm3DSACS(
                paymentConfirmationData: data,
                messageVersion: version
            ) { webViewResult in
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

    func interceptError(_ error: Error, for paymentProcess: PaymentProcess) -> Bool {
        let errorCode = (error as NSError).code
        switch errorCode {
        case 104:
            return handleChargeRequireCVCInput(paymentProcess: paymentProcess)
        default:
            return false
        }
    }

    func handleChargeRequireCVCInput(paymentProcess: PaymentProcess) -> Bool {
        guard let sourceViewController = uiProvider?.sourceViewControllerToPresent(),
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

    func getCustomerKey(for paymentProcess: PaymentProcess, customerOptions: CustomerOptions?) -> String? {
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

    func repeatChargeWithCVCInput(
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
