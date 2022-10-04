//
//
//  PaymentCardsProvider.swift
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

import Foundation
import TinkoffASDKCore

protocol IPaymentCardsProvider {
    func fetchActiveCards(_ completion: @escaping (Result<[PaymentCard], Error>) -> Void)
    func deactivateCard(cardId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class PaymentCardsProvider: IPaymentCardsProvider {
    // MARK: Internal Types

    enum FetchingStrategy {
        case cacheOnly
        case backendOnly
    }

    private enum Failure: Error {
        case inconsistentState
    }

    // MARK: Dependencies

    private let cardsManager: ICardsManager
    private let fetchingStrategy: FetchingStrategy

    init(cardsManager: ICardsManager, fetchingStrategy: FetchingStrategy) {
        self.cardsManager = cardsManager
        self.fetchingStrategy = fetchingStrategy
    }

    // MARK: IPaymentCardsProvider

    func fetchActiveCards(_ completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        switch fetchingStrategy {
        case .cacheOnly:
            completion(.success(cardsManager.getActiveCards()))
        case .backendOnly:
            cardsManager.getCards(completion: completion)
        }
    }

    func deactivateCard(cardId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        cardsManager.removeCard(
            cardId: cardId,
            completion: { result in
                completion(result.map { _ in () })
            }
        )
    }
}
