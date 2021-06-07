//
//
//  DefaultCardsController.swift
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

final class DefaultCardsController: CardsController {
    
    // Dependencies
    
    let customerKey: String
    private let cardsLoader: CardsLoader
    private let addCardController: AddCardController
    private let removeCardController: RemoveCardController
    
    // Listeners
    
    private var listeners = [WeakCardsControllerListener]()
    
    // State
    
    private var cards = [PaymentCard]()
    private var completions = [(Result<[PaymentCard], Error>) -> Void]()
    private var cardsLoadTask: DispatchWorkItem?
    
    private weak var uiProvider: CardsControllerUIProvider?
    
    // MARK: - Init
    
    init(customerKey: String,
         cardsLoader: CardsLoader,
         addCardController: AddCardController,
         removeCardController: RemoveCardController) {
        self.customerKey = customerKey
        self.cardsLoader = cardsLoader
        self.addCardController = addCardController
        self.removeCardController = removeCardController
    }
    
    // MARK: - CardsController
    
    func loadCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            self.completions.append(completion)
            self.cardsLoadTask?.cancel()
            self.cardsLoadTask = nil
            self.performCardsLoading()
        }
    }
    
    func getCards(predicates: PaymentCardPredicate...) -> [PaymentCard] {
        var returnValue = [PaymentCard]()
        DispatchQueue.safePerformOnMainQueueSync {
            returnValue = cards
        }

        returnValue = getFilteredCards(cards: returnValue, predicates: predicates)
        
        return returnValue
    }
    
    func addCard(cardData: CardData,
                 checkType: PaymentCardCheckType,
                 uiProvider: CardsControllerUIProvider,
                 completion: @escaping (Result<PaymentCard?, Error>) -> Void) {
        self.uiProvider = uiProvider
        addCardController.addCard(cardData: cardData,
                                  customerKey: customerKey,
                                  checkType: checkType,
                                  uiProvider: self) { [weak self] result in
            self?.addCardResultHandler(result: result,
                                       completion: completion)
        }
    }
    
    func removeCard(cardId: String,
                    completion: @escaping (Result<String, Error>) -> Void) {
        removeCardController.removeCard(cardId, customerKey: customerKey) { [weak self] result in
            self?.removeCardResultHandler(cardId: cardId, result: result, completion: completion)
        }
    }
    
    func addListener(_ listener: CardsControllerListener) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            var listeners = self.listeners.filter { $0.value != nil }
            listeners.append(.init(value: listener))
            self.listeners = listeners
        }
    }
    
    func removeListener(_ listener: CardsControllerListener) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            let listeners = self.listeners.filter { $0.value !== listener }
            self.listeners = listeners
        }
    }
}

// MARK: - Add/Remove Handling

private extension DefaultCardsController {
    func addCardResultHandler(result: Result<GetAddCardStatePayload, Error>,
                              completion: @escaping (Result<PaymentCard?, Error>) -> Void) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            switch result {
            case let .success(payload):
                if let cardId = payload.cardId {
                    self.loadCards { result in
                        switch result {
                        case let .success(cards):
                            completion(.success(cards.first(where: { $0.cardId == cardId })))
                        case .failure:
                            completion(.success(nil))
                        }
                    }
                } else {
                    completion(.success(nil))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func removeCardResultHandler(cardId: String,
                                 result: Result<RemoveCardPayload, Error>,
                                 completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            switch result {
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.loadCards { result in
                        switch result {
                        case .success:
                            completion(.success(cardId))
                        case .failure:
                            completion(.success(cardId))
                        }
                    }
                }
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension DefaultCardsController {
    func performCardsLoading() {
        let cardsLoadTask = createCardsLoadingTask()
        self.cardsLoadTask = cardsLoadTask
        cardsLoadTask.perform()
    }
    
    func handleLoadedCardsResult(_ result: Result<[PaymentCard], Error>) {
        cardsLoadTask = nil
        if case let .success(newCards) = result {
            cards = newCards
            notifyListenersAboutCardsUpdate()
        }
        callAndResetCompletions(result: result)
    }
    
    func createCardsLoadingTask() -> DispatchWorkItem {
        var task: DispatchWorkItem!
        task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.cardsLoader.loadCards(customerKey: self.customerKey) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
                    guard !task.isCancelled else { return }
                    self.handleLoadedCardsResult(result)
                }
            }
        }
        return task
    }
    
    func callAndResetCompletions(result: Result<[PaymentCard], Error>) {
        completions.forEach { $0(result) }
        completions = []
    }
    
    func notifyListenersAboutCardsUpdate() {
        listeners.forEach { $0.value?.cardsControllerDidUpdateCards(self) }
    }
    
    func getFilteredCards(cards: [PaymentCard], predicates: [PaymentCardPredicate]) -> [PaymentCard] {
        return cards.filter { card in
            var result = true
            for predicate in predicates {
                result = result && predicate.closure(card)
            }
            return result
        }
    }
}

extension DefaultCardsController: AddCardControllerUIProvider {
    func sourceViewControllerToPresent() -> UIViewController {
        guard let uiProvider = uiProvider else {
            assertionFailure("DefaultCardsController must has uiProvider")
            return UIViewController()
        }
        
        return uiProvider.sourceViewControllerToPresent()
    }
}

private struct WeakCardsControllerListener {
    weak var value: CardsControllerListener?
    init(value: CardsControllerListener) {
        self.value = value
    }
}
