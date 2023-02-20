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

protocol IPaymentFactory {
    func createPayment(
        paymentSource: PaymentSourceData,
        paymentFlow: PaymentFlow,
        paymentDelegate: PaymentProcessDelegate
    ) -> PaymentProcess?
}

struct PaymentFactory: IPaymentFactory {
    private let paymentsService: IAcquiringPaymentsService
    private let threeDsService: IAcquiringThreeDSService
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private let ipProvider: IIPAddressProvider

    init(
        paymentsService: IAcquiringPaymentsService,
        threeDsService: IAcquiringThreeDSService,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider,
        ipProvider: IIPAddressProvider
    ) {
        self.paymentsService = paymentsService
        self.threeDsService = threeDsService
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
        self.ipProvider = ipProvider
    }

    func createPayment(
        paymentSource: PaymentSourceData,
        paymentFlow: PaymentFlow,
        paymentDelegate: PaymentProcessDelegate
    ) -> PaymentProcess? {
        switch paymentSource {
        case .cardNumber, .savedCard, .applePay:
            return CardPaymentProcess(
                paymentsService: paymentsService,
                threeDsService: threeDsService,
                threeDSDeviceInfoProvider: threeDSDeviceInfoProvider,
                ipProvider: ipProvider,
                paymentSource: paymentSource,
                paymentFlow: paymentFlow,
                delegate: paymentDelegate
            )
        case .yandexPay:
            return YandexPayPaymentProcess(
                paymentFlow: paymentFlow,
                paymentSource: paymentSource,
                paymentService: paymentsService,
                threeDSService: threeDsService,
                threeDSDeviceInfoProvider: threeDSDeviceInfoProvider,
                delegate: paymentDelegate
            )
        case .parentPayment:
            return ChargePaymentProcess(
                paymentsService: paymentsService,
                paymentSource: paymentSource,
                paymentFlow: paymentFlow,
                delegate: paymentDelegate
            )
        }
    }
}
