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

/// Объект, предоставляющий для `PaymentController` UI-компоненты для совершения платежа
public protocol PaymentControllerUIProvider: AnyObject {
    /// webView, в котором выполнится запрос для прохождения 3DSChecking
    func hiddenWebViewToCollect3DSData() -> WKWebView
    /// viewController для модального показа экрана с 3DS Confirmation
    func presentingViewControllerToPresent3DS() -> UIViewController
}

/// Делегат событий для `PaymentController`
public protocol PaymentControllerDelegate: AnyObject {
    /// Оплата прошла успешно
    func paymentController(_ controller: PaymentController,
                           didFinishPayment: PaymentProcess,
                           with state: GetPaymentStatePayload,
                           cardId: String?,
                           rebillId: String?)
    
    /// Оплата была отменена
    func paymentController(_ controller: PaymentController,
                           paymentWasCancelled: PaymentProcess,
                           cardId: String?,
                           rebillId: String?)
    
    /// Возникла ошибка в процессе оплаты
    func paymentController(_ controller: PaymentController,
                           didFailed error: Error,
                           cardId: String?,
                           rebillId: String?)
}

/// Контроллер с помощью которого можно совершать оплату
public final class PaymentController {
    
    // MARK: - Dependencies
    
    private let acquiringSDK: AcquiringSdk
    private let paymentFactory: PaymentFactory
    private let threeDSHandler: ThreeDSWebViewHandler<GetPaymentStatePayload>
    private let threeDSDeviceParamsProvider: ThreeDSDeviceParamsProvider
    
    weak var uiProvider: PaymentControllerUIProvider?
    weak var delegate: PaymentControllerDelegate?
    
    // MARK: - State
    
    private var paymentProcess: PaymentProcess?
    private var threeDSViewController: ThreeDSViewController<GetPaymentStatePayload>?
    
    // MARK: - Init
    
    init(acquiringSDK: AcquiringSdk,
         paymentFactory: PaymentFactory,
         threeDSHandler: ThreeDSWebViewHandler<GetPaymentStatePayload>,
         threeDSDeviceParamsProvider: ThreeDSDeviceParamsProvider) {
        self.acquiringSDK = acquiringSDK
        self.paymentFactory = paymentFactory
        self.threeDSHandler = threeDSHandler
        self.threeDSDeviceParamsProvider = threeDSDeviceParamsProvider
    }
    
    deinit {
        paymentProcess?.cancel()
        paymentProcess = nil
    }
    
    // MARK: - Payments
    
    public func performInitPayment(paymentOptions: PaymentOptions,
                                   paymentSource: PaymentSourceData) {
        resetPaymentProcess { [weak self] in
            guard let self = self else { return }
            let paymentProcess = self.paymentFactory.createPayment(paymentSource: paymentSource,
                                                                   paymentFlow: .full(paymentOptions: paymentOptions),
                                                                   paymentDelegate: self)
            paymentProcess.start()
            self.paymentProcess = paymentProcess
        }
    }
    
    public func performFinishPayment(paymentId: PaymentId,
                                     paymentSource: PaymentSourceData,
                                     customerOptions: CustomerOptions) {
        resetPaymentProcess { [weak self] in
            guard let self = self else { return }
            let paymentProcess = self.paymentFactory.createPayment(paymentSource: paymentSource,
                                                                   paymentFlow: .finish(paymentId: paymentId,
                                                                                        customerOptions: customerOptions),
                                                                   paymentDelegate: self)
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
    
    func startThreeDSConfirmation(for paymentProcess: PaymentProcess,
                                  request: URLRequest,
                                  confirmationCancelled: @escaping () -> Void,
                                  completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        
        threeDSHandler.didCancel = {
            paymentProcess.cancel()
            confirmationCancelled()
        }
        
        threeDSHandler.didFinish = { result in
            completion(result)
        }
        
        DispatchQueue.main.async {
            self.presentThreeDSViewController(urlRequest: request)
            let threeDSViewController = ThreeDSViewController(urlRequest: request,
                                                              handler: self.threeDSHandler)
            let navigationController = UINavigationController(rootViewController: threeDSViewController)
            if #available(iOS 13.0, *) {
                navigationController.isModalInPresentation = true
            }
            self.uiProvider?.presentingViewControllerToPresent3DS().present(navigationController, animated: true, completion: nil)
            self.threeDSViewController = threeDSViewController
        }
    }
    
    func presentThreeDSViewController(urlRequest: URLRequest, completion: (() -> Void)? = nil) {
        dismissThreeDSViewControllerIfNeeded {
            let threeDSViewController = ThreeDSViewController(urlRequest: urlRequest,
                                                              handler: self.threeDSHandler)
            let navigationController = UINavigationController(rootViewController: threeDSViewController)
            if #available(iOS 13.0, *) {
                navigationController.isModalInPresentation = true
            }
            
            self.uiProvider?.presentingViewControllerToPresent3DS().present(navigationController,
                                                                            animated: true,
                                                                            completion: completion)
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
    func paymentDidFinish(_ paymentProcess: PaymentProcess,
                          with state: GetPaymentStatePayload,
                          cardId: String?,
                          rebillId: String?) {
        DispatchQueue.main.async {
            self.dismissThreeDSViewControllerIfNeeded { [weak self] in
                guard let self = self else { return }
                
                if state.status == .cancelled {
                    self.delegate?.paymentController(self,
                                                     paymentWasCancelled: paymentProcess,
                                                     cardId: cardId,
                                                     rebillId: rebillId)
                } else {
                    
                    self.delegate?.paymentController(self,
                                                     didFinishPayment: paymentProcess,
                                                     with: state,
                                                     cardId: cardId,
                                                     rebillId: rebillId)
                }
            }
            self.threeDSViewController = nil
            self.paymentProcess = nil
        }
    }
    
    func paymentDidFailed(_ paymentProcess: PaymentProcess,
                          with error: Error,
                          cardId: String?,
                          rebillId: String?) {
        DispatchQueue.main.async {
            self.dismissThreeDSViewControllerIfNeeded { [weak self] in
                guard let self = self else { return }
                self.delegate?.paymentController(self,
                                                 didFailed: error,
                                                 cardId: cardId,
                                                 rebillId: rebillId)
            }
            self.threeDSViewController = nil
            self.paymentProcess = nil
        }
    }
    
    func payment(_ paymentProcess: PaymentProcess,
                 needToCollect3DSData checking3DSURLData: Checking3DSURLData,
                 completion: @escaping (DeviceInfoParams) -> Void) {
        DispatchQueue.main.async {
            guard let webView = self.uiProvider?.hiddenWebViewToCollect3DSData(),
                  let request = try? self.acquiringSDK.createChecking3DSURL(data: checking3DSURLData) else {
                return
            }
            
            webView.load(request)
            completion(self.threeDSDeviceParamsProvider.deviceInfoParams)
        }
    }
    
    func payment(_ paymentProcess: PaymentProcess,
                 need3DSConfirmation data: Confirmation3DSData,
                 confirmationCancelled: @escaping () -> Void,
                 completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        do {
            let request = try self.acquiringSDK.createConfirmation3DSRequest(data: data)
            startThreeDSConfirmation(for: paymentProcess,
                                     request: request,
                                     confirmationCancelled: confirmationCancelled,
                                     completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    func payment(_ paymentProcess: PaymentProcess,
                 need3DSConfirmationACS data: Confirmation3DSDataACS,
                 version: String,
                 confirmationCancelled: @escaping () -> Void,
                 completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        do {
            let request = try self.acquiringSDK.createConfirmation3DSRequestACS(data: data,
                                                                                messageVersion: version)
            startThreeDSConfirmation(for: paymentProcess,
                                     request: request,
                                     confirmationCancelled: confirmationCancelled,
                                     completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
}
