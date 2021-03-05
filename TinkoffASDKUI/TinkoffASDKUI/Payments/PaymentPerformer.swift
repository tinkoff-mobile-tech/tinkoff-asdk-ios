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

final class PaymentPerformer {
    private let paymentFactory: PaymentFactory
    private var payments = [Payment]()
    
    init(paymentFactory: PaymentFactory) {
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
                                                   paymentFlow: .full(paymentOptions: paymentOptions))
        payment.start()
        payments.append(payment)
    }
    
    func performFinishPayment(paymentId: PaymentId,
                              paymentSource: PaymentSourceData,
                              customerOptions: CustomerOptions) {
        let payment = paymentFactory.createPayment(paymentSource: paymentSource,
                                                   paymentFlow: .finish(paymentId: paymentId,
                                                                        customerOptions: customerOptions))
        payment.start()
        payments.append(payment)
    }
}
