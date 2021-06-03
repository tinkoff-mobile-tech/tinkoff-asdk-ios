//
//
//  DefaultRemoveCardProcess.swift
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

final class DefaultRemoveCardProcess: RemoveCardProcess {
    
    // Dependencies
    
    private let acquiringSDK: AcquiringSdk
    private let customerKey: String
    private let cardId: String
    
    weak var delegate: RemoveCardProcessDelegate?
    
    // State
    
    private var isCancelled = Atomic(wrappedValue: false)
    private var currentRequest: Atomic<Cancellable>?
    
    // MARK: - Init
    
    init(acquiringSDK: AcquiringSdk,
         customerKey: String,
         cardId: String) {
        self.acquiringSDK = acquiringSDK
        self.customerKey = customerKey
        self.cardId = cardId
    }
    
    // MARK: - AddCardProcess
    
    func start() {
        removeCard(cardId: cardId, customerKey: customerKey)
    }

    func cancel() {
        isCancelled.store(newValue: true)
        currentRequest?.wrappedValue.cancel()
    }
}

private extension DefaultRemoveCardProcess {
    func removeCard(cardId: String,
                    customerKey: String) {
        let data = InitDeactivateCardData(cardId: cardId, customerKey: customerKey)
        let request = acquiringSDK.deactivateCard(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }
            self.handleRemoveResult(result, cardId: cardId)
        }
        currentRequest?.store(newValue: request)
    }
    
    func handleRemoveResult(_ result: Result<RemoveCardPayload, Error>,
                            cardId: String) {
        switch result {
        case let .success(payload):
            delegate?.removeCardProcessDidFinish(self, cardId: cardId, payload: payload)
        case let .failure(error):
            delegate?.removeCardProccessDidFailed(self, cardId: cardId, error: error)
        }
    }
}
