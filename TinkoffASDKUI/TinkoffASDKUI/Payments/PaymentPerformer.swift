//
//
//  PaymentPerformer.swift
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
    func paymentPerformer(_ performer: PaymentPerformer,
                          didFinishPayment: Payment,
                          with state: GetPaymentStatePayload,
                          cardId: String?,
                          rebillId: String?)
    
    func paymentPerformer(_ performer: PaymentPerformer,
                          didFailed error: Error)
}

final class PaymentPerformer {
    private let acquiringSDK: AcquiringSdk
    private let paymentFactory: PaymentFactory
    private var payments = [Payment]()
    
    weak var dataSource: PaymentPerformerDataSource?
    weak var delegate: PaymentPerformerDelegate?
    
    init(acquiringSDK: AcquiringSdk,
         paymentFactory: PaymentFactory) {
        self.acquiringSDK = acquiringSDK
        self.paymentFactory = paymentFactory
    }
    
    deinit {
        payments.forEach {
            $0.cancel()
        }
        payments = []
    }
    
    func performInitPayment(paymentOptions: PaymentOptions,
                            paymentSource: PaymentSourceData) {
        let payment = paymentFactory.createPayment(paymentSource: paymentSource,
                                                   paymentFlow: .full(paymentOptions: paymentOptions),
                                                   paymentDelegate: self)
        payment.start()
        payments.append(payment)
    }
    
    func performFinishPayment(paymentId: PaymentId,
                              paymentSource: PaymentSourceData,
                              customerOptions: CustomerOptions) {
        let payment = paymentFactory.createPayment(paymentSource: paymentSource,
                                                   paymentFlow: .finish(paymentId: paymentId,
                                                                        customerOptions: customerOptions),
                                                   paymentDelegate: self)
        payment.start()
        payments.append(payment)
    }
}

extension PaymentPerformer: PaymentDelegate {
    func paymentDidFinish(_ payment: Payment,
                          with state: GetPaymentStatePayload,
                          cardId: String?,
                          rebillId: String?) {
        delegate?.paymentPerformer(self,
                                   didFinishPayment: payment,
                                   with: state,
                                   cardId: cardId,
                                   rebillId: rebillId)
    }
    
    func paymentDidFailed(_ payment: Payment,
                          with error: Error) {
        delegate?.paymentPerformer(self, didFailed: error)
    }
    
    func payment(_ payment: Payment,
                 needToCollect3DSData checking3DSURLData: Checking3DSURLData,
                 completion: @escaping (DeviceInfoParams) -> Void) {
        guard let webView = dataSource?.hiddenWebViewToCollect3DSData(),
              let request = try? acquiringSDK.createChecking3DSURL(data: checking3DSURLData) else {
            return
        }
        
        webView.loadRequest(request)
        
        // TODO: Device Info and call completion
    }
    
    func payment(_ payment: Payment,
                 need3DSConfirmation data: Confirmation3DSData,
                 completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        guard let viewController = dataSource?.viewControllerToPresent() else {
            fatalError()
        }
        
        // TODO: Present web view
    }
    
    func payment(_ payment: Payment,
                 need3DSConfirmationACS data: Confirmation3DSDataACS,
                 completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        guard let viewController = dataSource?.viewControllerToPresent() else {
            fatalError()
        }
        
        // TODO: Present web view
    }
}
