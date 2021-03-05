//
//
//  Payment.swift
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

enum PaymentFlow {
    case full(paymentOptions: PaymentOptions)
    case finish(paymentId: PaymentId, customerOptions: CustomerOptions)
}

protocol PaymentDelegate: AnyObject {
    func paymentDidFinish(_ payment: Payment,
                          with state: GetPaymentStatePayload,
                          cardId: String?,
                          rebillId: String?)
    func paymentDidFailed(_ payment: Payment,
                          with error: Error)
    func payment(_ payment: Payment,
                 needToCollect3DSData checking3DSURLData: Checking3DSURLData,
                 completion: @escaping (DeviceInfoParams) -> Void)
    func payment(_ payment: Payment,
                 need3DSConfirmation data: Confirmation3DSData,
                 completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void)
    func payment(_ payment: Payment,
                 need3DSConfirmationACS data: Confirmation3DSDataACS,
                 completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void)
}

protocol Payment: Cancellable {
    func start()
}
