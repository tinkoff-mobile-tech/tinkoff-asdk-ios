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
    private let addingCardController: CardAddingController
    private let acquiringSDK: AcquiringSdk
    
    // Listeners
    
    private var listeners = [WeakCardsControllerListener]()
    
    // State
    
    private var cards = [PaymentCard]()
    private var completions = [(Result<[PaymentCard], Error>) -> Void]()
    private var cardsLoadTask: DispatchWorkItem?
    
    private var addCardCompletion: ((Result<PaymentCard?, Error>) -> Void)?
    private weak var uiProvider: CardsControllerUIProvider?
    
    // MARK: - Init
    
    init(customerKey: String,
         cardsLoader: CardsLoader,
         addingCardController: CardAddingController,
         acquiringSDK: AcquiringSdk) {
        self.customerKey = customerKey
        self.cardsLoader = cardsLoader
        self.addingCardController = addingCardController
        self.acquiringSDK = acquiringSDK
    }
    
    // MARK: - CardsController
    
    func loadCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        DispatchQueue.safePerformOnMainQueueSync {
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
        self.addCardCompletion = completion
        self.uiProvider = uiProvider
        addingCardController.addCard(cardData: cardData, customerKey: customerKey, checkType: checkType)
    }
    
    func addListener(_ listener: CardsControllerListener) {
        DispatchQueue.safePerformOnMainQueueSync {
            var listeners = self.listeners.filter { $0.value != nil }
            listeners.append(.init(value: listener))
            self.listeners = listeners
        }
    }
    
    func removeListener(_ listener: CardsControllerListener) {
        DispatchQueue.safePerformOnMainQueueSync {
            let listeners = self.listeners.filter { $0.value !== listener }
            self.listeners = listeners
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
                DispatchQueue.safePerformOnMainQueueSync {
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

extension DefaultCardsController: CardAddingControllerDelegate {
    func cardAddingController(_ controller: CardAddingController,
                              didFinish: AddCardProcess,
                              state: GetAddCardStatePayload) {
        performAsyncOnSyncQueue { [addCardCompletion] in
            if let cardId = state.cardId {
                self.loadCards { result in
                    switch result {
                    case let .success(cards):
                        addCardCompletion?(.success(cards.first(where: { $0.cardId == cardId })))
                    case .failure:
                        addCardCompletion?(.success(nil))
                    }
                }
            } else {
                self.addCardCompletion?(.success(nil))
            }
        }
    }
    
    func cardAddingController(_ controller: CardAddingController,
                              addCardWasCancelled: AddCardProcess) {
        performAsyncOnSyncQueue {
            self.addCardCompletion?(.failure(CardsControllerError.cancelled))
        }
    }
    
    func cardAddingController(_ controller: CardAddingController,
                              didFailed error: Error) {
        performAsyncOnSyncQueue {
            self.addCardCompletion?(.failure(error))
        }
    }
}

extension DefaultCardsController: CardAddingControllerUIProvider {
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
