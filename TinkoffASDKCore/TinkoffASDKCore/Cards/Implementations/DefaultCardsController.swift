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


import Foundation

final class DefaultCardsController: CardsController {
    
    // Dependencies
    
    let customerKey: String
    private let cardsLoader: CardsLoader
    private let queue: DispatchQueue
    
    // Listeners
    
    private var listeners = [WeakCardsControllerListener]()
    
    // State
    
    private var cards = [PaymentCard]()
    private var completions = [(Result<[PaymentCard], Error>) -> Void]()
    private var cardsLoadTask: DispatchWorkItem?
    
    // MARK: - Init
    
    init(customerKey: String,
         cardsLoader: CardsLoader,
         queue: DispatchQueue = .main) {
        self.customerKey = customerKey
        self.cardsLoader = cardsLoader
        self.queue = queue
    }
    
    // MARK: - CardsController
    
    func loadCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        queue.async {
            self.completions.append(completion)
            self.cardsLoadTask?.cancel()
            self.cardsLoadTask = nil
            self.performCardsLoading()
        }
    }
    
    func getCards() -> [PaymentCard] {
        cards
    }
    
    func addListener(_ listener: CardsControllerListener) {
        var listeners = self.listeners.filter { $0.value != nil }
        listeners.append(.init(value: listener))
        self.listeners = listeners
    }
    
    func removeListener(_ listener: CardsControllerListener) {
        let listeners = self.listeners.filter { $0.value !== listener }
        self.listeners = listeners
    }
}

private extension DefaultCardsController {
    func performCardsLoading() {
        let cardsLoadTask = createCardsLoadingTask()
        self.cardsLoadTask = cardsLoadTask
        self.queue.async(execute: cardsLoadTask)
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
                self.queue.async {
                    guard task.isCancelled else { return }
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
}

private struct WeakCardsControllerListener {
    weak var value: CardsControllerListener?
    init(value: CardsControllerListener) {
        self.value = value
    }
}
