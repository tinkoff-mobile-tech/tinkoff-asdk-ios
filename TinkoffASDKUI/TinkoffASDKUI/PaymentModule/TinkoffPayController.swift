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
    private let tinkoffPayStatusCacheLifeTime: TimeInterval

    private var tinkoffPayAvailableCachedResult: GetTinkoffPayStatusResponse.Status?

    init(
        sdk: AcquiringSdk,
        tinkoffPayStatusCacheLifeTime: TimeInterval = 300
    ) {
        self.sdk = sdk
        self.tinkoffPayStatusCacheLifeTime = tinkoffPayStatusCacheLifeTime
    }

    func checkIfTinkoffPayAvailable(completion: @escaping (Result<GetTinkoffPayStatusResponse.Status, Error>) -> Void) -> Cancellable {
        if let tinkoffPayAvailableCachedResult = tinkoffPayAvailableCachedResult {
            completion(.success(tinkoffPayAvailableCachedResult))
            return EmptyCancellable()
        }

        return sdk.getTinkoffPayStatus { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .success(response):
                    self?.tinkoffPayAvailableCachedResult = response.status
                    self?.startTinkoffPayCacheResetTimer()
                    completion(.success(response.status))
                }
            }
        }
    }

    func getTinkoffPayLink(
        paymentId: Int64,
        version: GetTinkoffPayStatusResponse.Status.Version,
        completion: @escaping (Result<URL, Error>) -> Void
    ) -> Cancellable {
        return sdk.getTinkoffPayLink(
            paymentId: paymentId,
            version: version
        ) { result in
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

private extension TinkoffPayController {
    func startTinkoffPayCacheResetTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + tinkoffPayStatusCacheLifeTime) {
            self.tinkoffPayAvailableCachedResult = nil
        }
    }
}
