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

public typealias PaymentId = String

/// Объект, предоставляющий для `PaymentController` UI-компоненты для совершения платежа
public protocol PaymentControllerUIProvider: AnyObject {
    /// webView, в котором выполнится запрос для прохождения 3DSChecking
    func hiddenWebViewToCollect3DSData() -> WKWebView
    /// viewController для модального показа экранов, необходимость в которых может возникнуть в процессе оплаты
    func sourceViewControllerToPresent() -> UIViewController
}

/// Делегат событий для `PaymentController`
public protocol PaymentControllerDelegate: AnyObject {
    /// Оплата прошла успешно
    func paymentController(
        _ controller: PaymentController,
        didFinishPayment: PaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    )

    /// Оплата была отменена
    func paymentController(
        _ controller: PaymentController,
        paymentWasCancelled: PaymentProcess,
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
public final class PaymentController {

    // MARK: - Dependencies

    private let acquiringSDK: AcquiringSdk
    private let paymentFactory: PaymentFactory
    private let threeDSHandler: ThreeDSWebViewHandler<GetPaymentStatePayload>
    private let threeDSDeviceParamsProvider: ThreeDSDeviceParamsProvider
    // App based threeDS
    private let tdsController: TDSController

    weak var uiProvider: PaymentControllerUIProvider?
    weak var delegate: PaymentControllerDelegate?
    weak var dataSource: PaymentControllerDataSource?

    // MARK: - State

    private var paymentProcess: PaymentProcess?
    private var threeDSViewController: ThreeDSViewController<GetPaymentStatePayload>?

    // MARK: - Temporary until refactor PaymentView!

    private let acquiringUISDK: AcquiringUISDK

    // MARK: - Init

    init(
        acquiringSDK: AcquiringSdk,
        paymentFactory: PaymentFactory,
        threeDSHandler: ThreeDSWebViewHandler<GetPaymentStatePayload>,
        threeDSDeviceParamsProvider: ThreeDSDeviceParamsProvider,
        tdsController: TDSController,
        acquiringUISDK: AcquiringUISDK /* temporary*/
    ) {
        self.acquiringSDK = acquiringSDK
        self.paymentFactory = paymentFactory
        self.threeDSHandler = threeDSHandler
        self.threeDSDeviceParamsProvider = threeDSDeviceParamsProvider
        self.tdsController = tdsController
        self.acquiringUISDK = acquiringUISDK
    }

    deinit {
        paymentProcess?.cancel()
        paymentProcess = nil
    }

    // MARK: - Payments

    public func performInitPayment(
        paymentOptions: PaymentOptions,
        paymentSource: PaymentSourceData
    ) {
        resetPaymentProcess { [weak self] in
            guard let self = self else { return }
            let paymentProcess = self.paymentFactory.createPayment(
                paymentSource: paymentSource,
                paymentFlow: .full(paymentOptions: paymentOptions),
                paymentDelegate: self
            )

            guard let paymentProcess = paymentProcess else {
                return
            }
            paymentProcess.start()
            self.paymentProcess = paymentProcess
        }
    }

    public func performFinishPayment(
        paymentId: PaymentId,
        paymentSource: PaymentSourceData,
        customerOptions: CustomerOptions
    ) {
        resetPaymentProcess { [weak self] in
            guard let self = self else { return }
            let paymentProcess = self.paymentFactory.createPayment(
                paymentSource: paymentSource,
                paymentFlow: .finish(
                    paymentId: paymentId,
                    customerOptions: customerOptions
                ),
                paymentDelegate: self
            )

            guard let paymentProcess = paymentProcess else {
                return
            }

            paymentProcess.start()
            self.paymentProcess = paymentProcess
        }
    }
}

private extension PaymentController {
    func resetPaymentProcess(completion: @escaping () -> Void) {
        paymentProcess?.cancel()
        paymentProcess = nil

        dismissThreeDSViewControllerIfNeeded { [weak self] in
            self?.threeDSViewController = nil
            completion()
        }
    }

    func startThreeDSConfirmation(
        for paymentProcess: PaymentProcess,
        request: URLRequest,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {

        threeDSHandler.didCancel = {
            paymentProcess.cancel()
            confirmationCancelled()
        }

        threeDSHandler.didFinish = { result in
            completion(result)
        }

        DispatchQueue.main.async {
            self.presentThreeDSViewController(urlRequest: request)
        }
    }

    func presentThreeDSViewController(urlRequest: URLRequest, completion: (() -> Void)? = nil) {
        dismissThreeDSViewControllerIfNeeded {
            let threeDSViewController = ThreeDSViewController(
                urlRequest: urlRequest,
                handler: self.threeDSHandler
            )
            let navigationController = UINavigationController(rootViewController: threeDSViewController)
            if #available(iOS 13.0, *) {
                navigationController.isModalInPresentation = true
            }

            self.uiProvider?.sourceViewControllerToPresent().present(
                navigationController,
                animated: true,
                completion: completion
            )
            self.threeDSViewController = threeDSViewController
        }
    }

    func dismissThreeDSViewControllerIfNeeded(completion: @escaping () -> Void) {
        guard let threeDSViewController = threeDSViewController,
              let threeDSPresentingViewController = threeDSViewController.presentingViewController else {
            completion()
            return
        }

        if threeDSViewController.isBeingPresented {
            threeDSPresentingViewController.transitionCoordinator?.animate(alongsideTransition: nil, completion: { _ in
                threeDSPresentingViewController.dismiss(animated: true, completion: completion)
            })
        } else if threeDSViewController.isBeingDismissed {
            threeDSPresentingViewController.transitionCoordinator?.animate(alongsideTransition: nil, completion: { _ in
                completion()
            })
        } else {
            threeDSPresentingViewController.dismiss(animated: true, completion: completion)
        }
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
        DispatchQueue.main.async {
            self.dismissThreeDSViewControllerIfNeeded { [weak self] in
                guard let self = self else { return }

                if state.status == .cancelled {
                    self.delegate?.paymentController(
                        self,
                        paymentWasCancelled: paymentProcess,
                        cardId: cardId,
                        rebillId: rebillId
                    )
                } else {
                    self.delegate?.paymentController(
                        self,
                        didFinishPayment: paymentProcess,
                        with: state,
                        cardId: cardId,
                        rebillId: rebillId
                    )
                }
            }
            self.threeDSViewController = nil
            self.paymentProcess = nil
        }
    }

    func paymentDidFailed(
        _ paymentProcess: PaymentProcess,
        with error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        DispatchQueue.main.async {
            self.dismissThreeDSViewControllerIfNeeded { [weak self] in
                guard let self = self else { return }
                guard !self.interceptError(error, for: paymentProcess) else { return }
                self.delegate?.paymentController(
                    self,
                    didFailed: error,
                    cardId: cardId,
                    rebillId: rebillId
                )
            }
            self.threeDSViewController = nil
            self.paymentProcess = nil
        }
    }

    func payment(
        _ paymentProcess: PaymentProcess,
        needToCollect3DSData checking3DSURLData: Checking3DSURLData,
        completion: @escaping (DeviceInfoParams) -> Void
    ) {
        DispatchQueue.main.async {
            guard let webView = self.uiProvider?.hiddenWebViewToCollect3DSData(),
                  let request = try? self.acquiringSDK.createChecking3DSURL(data: checking3DSURLData) else {
                return
            }

            webView.load(request)
            completion(self.threeDSDeviceParamsProvider.deviceInfoParams)
        }
    }

    func payment(
        _ paymentProcess: PaymentProcess,
        need3DSConfirmation data: Confirmation3DSData,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        do {
            let request = try acquiringSDK.createConfirmation3DSRequest(data: data)
            startThreeDSConfirmation(
                for: paymentProcess,
                request: request,
                confirmationCancelled: confirmationCancelled,
                completion: completion
            )
        } catch {
            completion(.failure(error))
        }
    }

    func payment(
        _ paymentProcess: PaymentProcess,
        need3DSConfirmationACS data: Confirmation3DSDataACS,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        do {
            let request = try acquiringSDK.createConfirmation3DSRequestACS(
                data: data,
                messageVersion: version
            )
            startThreeDSConfirmation(
                for: paymentProcess,
                request: request,
                confirmationCancelled: confirmationCancelled,
                completion: completion
            )
        } catch {
            completion(.failure(error))
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
        let parentPaymentId: PaymentId?

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

    func getCustomerKey(for paymentProcess: PaymentProcess, customerOptions: CustomerOptions) -> String? {
        let customerKey: String?
        if case let .customer(key, _) = customerOptions.customer {
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
        parentPaymentId: PaymentId,
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

        acquiringUISDK.presentPaymentView(
            on: sourceViewController,
            paymentData: PaymentInitData(amount: newOrderOptions.amount, orderId: newOrderOptions.orderId, customerKey: customerKey),
            parentPatmentId: Int64(parentPaymentId)!,
            configuration: viewConfiguration,
            completionHandler: { _ in
            }
        )
    }
}
