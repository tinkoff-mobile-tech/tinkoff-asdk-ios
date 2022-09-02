//
//  PayController.swift
//  TinkoffASDKUI
//
//  Created by Serebryaniy Grigoriy on 14.04.2022.
//

import Foundation

import Foundation
import TinkoffASDKCore

final class PayController {
    private let sdk: AcquiringSdk
    
    init(sdk: AcquiringSdk) {
        self.sdk = sdk
    }
    
    func initPayment(with initData: PaymentInitData,
                     completion: @escaping (Result<Int64, Error>) -> Void) {
        _ = sdk.paymentInit(data: initData, completionHandler: { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    completion(.success(response.paymentId))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        })
    }
}

private extension PayController {
    
}
