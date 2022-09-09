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

    private let dataProvider: CardListDataProvider
    private let fetchingStrategy: FetchingStrategy

    init(dataProvider: CardListDataProvider, fetchingStrategy: FetchingStrategy) {
        self.dataProvider = dataProvider
        self.fetchingStrategy = fetchingStrategy
    }

    // MARK: IPaymentCardsProvider

    func fetchActiveCards(_ completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        switch fetchingStrategy {
        case .cacheOnly:
            completion(.success(dataProvider.allItems()))
        case .backendOnly:
            dataProvider.fetch(startHandler: nil) { cards, error in
                let result: Result<[PaymentCard], Error> = Result {
                    if let error = error {
                        throw error
                    }
                    return cards ?? []
                }
                completion(result)
            }
        }
    }

    func deactivateCard(cardId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        dataProvider.deactivateCard(cardId: cardId, startHandler: nil) { paymentCard in
            // Из-за некорректной реализации `CardListDataProvider` приходится исходить
            // из того, что отсутствие `PaymentCard` в `completion` - признак возникшей ошибки
            let result: Result<Void, Error> = paymentCard == nil
                ? .failure(Failure.inconsistentState)
                : .success(())

            completion(result)
        }
    }
}
