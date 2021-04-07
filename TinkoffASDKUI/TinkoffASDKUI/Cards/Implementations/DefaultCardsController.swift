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
    private let acquiringSDK: AcquiringSdk
    
    // Listeners
    
    private var listeners = [WeakCardsControllerListener]()
    
    // State
    
    private var cards = [PaymentCard]()
    private var completions = [(Result<[PaymentCard], Error>) -> Void]()
    private var cardsLoadTask: DispatchWorkItem?
    
    private var addCardProcess: AddCardProcess?
    private var addCardCompletion: ((Result<PaymentCard?, Error>) -> Void)?
    
    // MARK: - Init
    
    init(customerKey: String,
         cardsLoader: CardsLoader,
         acquiringSDK: AcquiringSdk) {
        self.customerKey = customerKey
        self.cardsLoader = cardsLoader
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
                 uiProvider: CardsControllerAddCardProcessUIProvider,
                 completion: @escaping (Result<PaymentCard?, Error>) -> Void) {
        self.addCardCompletion = completion
        let addCardProcess = DefaultAddCardProcess(acquiringSDK: acquiringSDK,
                                                   customerKey: customerKey)
        addCardProcess.addCard(cardData: cardData, checkType: checkType)
        addCardProcess.delegate = self
        self.addCardProcess = addCardProcess
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

extension DefaultCardsController: AddCardProcessDelegate {
    func addCardProcessDidFinish(_ addCardProcess: AddCardProcess, state: GetAddCardStatePayload) {
        loadCards { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(cards):
                self.addCardCompletion?(.success(cards.first(where: { $0.cardId == state.cardId })))
            case .failure:
                self.addCardCompletion?(.success(nil))
            }
        }
    }
    
    func addCardProcessDidFailed(_ addCardProcess: AddCardProcess, error: Error) {
        self.addCardCompletion?(.failure(error))
    }
    
    func addCardProcess(_ addCardProcess: AddCardProcess, need3DSConfirmation data: Confirmation3DSData, confirmationCancelled: @escaping () -> Void, completion: @escaping (Result<AddCardStatusResponse, Error>) -> Void) {
        
    }
    
    func addCardProcess(_ addCardProcess: AddCardProcess, need3DSConfirmationACS data: Confirmation3DSDataACS, confirmationCancelled: @escaping () -> Void, completion: @escaping (Result<AddCardStatusResponse, Error>) -> Void) {
        
    }
    
    func addCardProcess(_ addCardProcess: AddCardProcess, needRandomAmountConfirmation requestKey: String, confirmationCancelled: @escaping () -> Void, completion: @escaping (Result<AddCardStatusResponse, Error>) -> Void) {
        
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

private struct WeakCardsControllerListener {
    weak var value: CardsControllerListener?
    init(value: CardsControllerListener) {
        self.value = value
    }
}
