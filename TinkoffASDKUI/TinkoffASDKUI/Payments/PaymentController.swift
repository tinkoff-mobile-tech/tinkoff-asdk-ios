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

protocol PaymentPerformerDataSource: AnyObject {
    func hiddenWebViewToCollect3DSData() -> UIWebView?
    func viewControllerToPresent() -> UIViewController
}

protocol PaymentPerformerDelegate: AnyObject {
    func paymentPerformer(_ performer: PaymentController,
                          didFinishPayment: Payment,
                          with state: GetPaymentStatePayload,
                          cardId: String?,
                          rebillId: String?)
    
    func paymentPerformer(_ performer: PaymentController,
                          didFailed error: Error)
}

final class PaymentController: NSObject {
    private let acquiringSDK: AcquiringSdk
    private let paymentFactory: PaymentFactory
    private let threeDSHandler: ThreeDSWebViewHandler<GetPaymentStatePayload>
    private var payment: Payment?
    
    private var threeDSViewController: ThreeDSViewController<GetPaymentStatePayload>?
    
    weak var dataSource: PaymentPerformerDataSource?
    weak var delegate: PaymentPerformerDelegate?
    
    init(acquiringSDK: AcquiringSdk,
         paymentFactory: PaymentFactory,
         threeDSHandler: ThreeDSWebViewHandler<GetPaymentStatePayload>) {
        self.acquiringSDK = acquiringSDK
        self.paymentFactory = paymentFactory
        self.threeDSHandler = threeDSHandler
    }
    
    deinit {
        payment?.cancel()
    }
    
    func performInitPayment(paymentOptions: PaymentOptions,
                            paymentSource: PaymentSourceData) {
        resetPaymentProcessIfNeeded { [weak self] in
            guard let self = self else { return }
            let payment = self.paymentFactory.createPayment(paymentSource: paymentSource,
                                                            paymentFlow: .full(paymentOptions: paymentOptions),
                                                            paymentDelegate: self)
            payment.start()
            self.payment = payment
        }
    }
    
    func performFinishPayment(paymentId: PaymentId,
                              paymentSource: PaymentSourceData,
                              customerOptions: CustomerOptions) {
        resetPaymentProcessIfNeeded { [weak self] in
            guard let self = self else { return }
            let payment = self.paymentFactory.createPayment(paymentSource: paymentSource,
                                                            paymentFlow: .finish(paymentId: paymentId,
                                                                                 customerOptions: customerOptions),
                                                            paymentDelegate: self)
            payment.start()
            self.payment = payment
        }
    }
}

private extension PaymentController {
    func resetPaymentProcessIfNeeded(completion: @escaping () -> Void) {
        if let currentPayment = self.payment {
            currentPayment.cancel()
            self.payment = nil
        }
        
        if let threeDSViewController = threeDSViewController,
           let threeDSPresentingViewController = threeDSViewController.presentingViewController {
            
            if threeDSPresentingViewController.isBeingDismissed {
                threeDSPresentingViewController.transitionCoordinator?.animate(alongsideTransition: nil,
                                                                               completion: { (_) in
                                                                                completion()
                                                                               })
            } else {
                threeDSPresentingViewController.dismiss(animated: true) {
                    completion()
                }
            }
            self.threeDSViewController = nil
        } else {
            completion()
        }
    }
    
    func startThreeDSConfirmation(for payment: Payment,
                                  request: URLRequest,
                                  confirmationCancelled: @escaping () -> Void,
                                  completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        
        threeDSHandler.didCancel = {
            payment.cancel()
            confirmationCancelled()
        }
        
        threeDSHandler.didFinish = { result in
            completion(result)
        }
        
        DispatchQueue.main.async {
            let threeDSViewController = ThreeDSViewController(urlRequest: request,
                                                              handler: self.threeDSHandler)
            let navigationController = UINavigationController(rootViewController: threeDSViewController)
            if #available(iOS 13.0, *) {
                navigationController.isModalInPresentation = true
            }
            self.dataSource?.viewControllerToPresent().present(navigationController, animated: true, completion: nil)
            self.threeDSViewController = threeDSViewController
        }
    }
}

// MARK: - PaymentDelegate

extension PaymentController: PaymentDelegate {
    func paymentDidFinish(_ payment: Payment,
                          with state: GetPaymentStatePayload,
                          cardId: String?,
                          rebillId: String?) {
        DispatchQueue.main.async {
            self.threeDSViewController?.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                self.delegate?.paymentPerformer(self,
                                                didFinishPayment: payment,
                                                with: state,
                                                cardId: cardId,
                                                rebillId: rebillId)
            })
            self.threeDSViewController = nil
        }
    }
    
    func paymentDidFailed(_ payment: Payment,
                          with error: Error) {
        threeDSViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.delegate?.paymentPerformer(self, didFailed: error)
        })
    }
    
    func payment(_ payment: Payment,
                 needToCollect3DSData checking3DSURLData: Checking3DSURLData,
                 completion: @escaping (DeviceInfoParams) -> Void) {
        guard let webView = dataSource?.hiddenWebViewToCollect3DSData(),
              let request = try? acquiringSDK.createChecking3DSURL(data: checking3DSURLData) else {
            return
        }
        
        webView.loadRequest(request)
    }
    
    func payment(_ payment: Payment,
                 need3DSConfirmation data: Confirmation3DSData,
                 confirmationCancelled: @escaping () -> Void,
                 completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        do {
            let request = try self.acquiringSDK.createConfirmation3DSRequest(data: data)
            startThreeDSConfirmation(for: payment,
                                     request: request,
                                     confirmationCancelled: confirmationCancelled,
                                     completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    func payment(_ payment: Payment,
                 need3DSConfirmationACS data: Confirmation3DSDataACS,
                 version: String?,
                 confirmationCancelled: @escaping () -> Void,
                 completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        do {
            let request = try self.acquiringSDK.createConfirmation3DSRequestACS(data: data,
                                                                                messageVersion: version)
            startThreeDSConfirmation(for: payment,
                                     request: request,
                                     confirmationCancelled: confirmationCancelled,
                                     completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
}
