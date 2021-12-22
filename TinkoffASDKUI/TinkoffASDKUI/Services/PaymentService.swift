//
//
//  PaymentService.swift
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

public protocol PaymentService {
    func initPaymentWith(paymentData: PaymentInitData, completion: @escaping (Result<PaymentInitResponse, Error>) -> Void)
    func getPaymentStatus(paymentId: Int64, completion: @escaping (Result<PaymentStatusResponse, Error>) -> Void)
}
 
final class DefaultPaymentService: PaymentService {
    private let coreSDK: AcquiringSdk
    
    public init(coreSDK: AcquiringSdk) {
        self.coreSDK = coreSDK
    }
    
    func initPaymentWith(paymentData: PaymentInitData, completion: @escaping (Result<PaymentInitResponse, Error>) -> Void) {
        _ = coreSDK.paymentInit(data: paymentData) { result in
            completion(result)
        }
    }
    
    func getPaymentStatus(paymentId: Int64, completion: @escaping (Result<PaymentStatusResponse, Error>) -> Void) {
        _ = coreSDK.paymentOperationStatus(data: .init(paymentId: paymentId), completionHandler: { result in
            completion(result)
        })
    }
}
