//
//
//  SBPPaymentService.swift
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

public protocol SBPPaymentService {
    func createSBPUrl(paymentId: Int64,
                      completion: ((Result<URL, Error>) -> Void)?)
}

public final class DefaultSBPPaymentService: SBPPaymentService {
    private let coreSDK: AcquiringSdk
    
    public init(coreSDK: AcquiringSdk) {
        self.coreSDK = coreSDK
    }
    
    public func createSBPUrl(paymentId: Int64,
                             completion: ((Result<URL, Error>) -> Void)?) {
        requestSBPUrl(paymentId: paymentId, completion: completion)
    }
}

private extension DefaultSBPPaymentService {
    func requestSBPUrl(paymentId: Int64,
                       completion: ((Result<URL, Error>) -> Void)?) {
        let paymentInvoice = PaymentInvoiceQRCodeData(paymentId: paymentId, paymentInvoiceType: .url)
        _ = coreSDK.paymentInvoiceQRCode(data: paymentInvoice) { result in
            switch result {
            case let .failure(error):
                completion?(.failure(error))
            case let .success(sbpResponse):
                guard let url = URL(string: sbpResponse.qrCodeData) else {
                    return
                }
                completion?(.success(url))
            }
        }
    }
}


