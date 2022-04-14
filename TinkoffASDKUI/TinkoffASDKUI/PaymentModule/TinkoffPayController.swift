//
//  TinkoffPayController.swift
//  TinkoffASDKUI
//
//  Created by Serebryaniy Grigoriy on 14.04.2022.
//

import Foundation
import TinkoffASDKCore

final class TinkoffPayController {
    private let sdk: AcquiringSdk
    
    init(sdk: AcquiringSdk) {
        self.sdk = sdk
    }
    
    func checkIfTinkoffPayAvailable(completion: @escaping (Result<GetTinkoffPayStatusResponse.Status, Error>) -> Void) -> Cancellable {
        return sdk.getTinkoffPayStatus { result in
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .success(response):
                    completion(.success(response.status))
                }
            }
        }
    }
    
    func getTinkoffPayLink(paymentId: Int64,
                           version: GetTinkoffPayStatusResponse.Status.Version,
                           completion: @escaping (Result<URL, Error>) -> Void) -> Cancellable {
        return sdk.getTinkoffPayLink(paymentId: paymentId,
                                     version: version) { result in
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .success(response):
                    completion(.success(response.redirectUrl))
                }
            }
        }
    }
}
