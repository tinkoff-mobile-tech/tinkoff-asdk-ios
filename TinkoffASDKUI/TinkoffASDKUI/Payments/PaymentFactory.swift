//
//
//  PaymentFactory.swift
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

struct PaymentFactory {
    private let acquiringSDK: AcquiringSdk
    
    init(acquiringSDK: AcquiringSdk) {
        self.acquiringSDK = acquiringSDK
    }
    
    func createPayment(paymentSource: PaymentSourceData,
                       paymentFlow: PaymentFlow,
                       paymentDelegate: PaymentProcessDelegate) -> PaymentProcess {
        switch paymentSource {
        case .cardNumber, .savedCard, .paymentData:
            return CardPaymentProcess(acquiringSDK: acquiringSDK,
                                      paymentSource: paymentSource,
                                      paymentFlow: paymentFlow,
                                      delegate: paymentDelegate)
        case .parentPayment:
            // TODO: Next PR
            print("return Charge")
            fatalError()
        case .unknown:
            // TODO: Log error
            fatalError()
        }
    }
}
