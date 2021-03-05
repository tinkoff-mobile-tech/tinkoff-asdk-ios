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

protocol Payment: Cancellable {
    var onSuccess: ((_ state: GetPaymentStatePayload, _ cardId: String?, _ rebillId: String?) -> Void)? { get set }
    var needToCollect3DSData: ((Checking3DSURLData) -> DeviceInfoParams)? { get set }
    var need3DSConfirmation: ((Confirmation3DSData) -> GetPaymentStatePayload)? { get set }
    var need3DSConfirmationACS: ((Confirmation3DSDataACS) -> GetPaymentStatePayload)? { get set }
    var onFailed: ((Error) -> Void)? { get set }
    
    func start()
}
