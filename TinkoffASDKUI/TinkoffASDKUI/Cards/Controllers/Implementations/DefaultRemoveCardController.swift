//
//
//  DefaultRemoveCardController.swift
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

final class DefaultRemoveCardController: RemoveCardController {
    
    // Dependencies
    
    private let acquiringSDK: AcquiringSdk
    
    // State
    
    private var processes = [String: RemoveCardProcess]()
    private var completions = [String: [(Result<RemoveCardPayload, Error>) -> Void]]()
    
    // MARK: - Init
    
    init(acquiringSDK: AcquiringSdk) {
        self.acquiringSDK = acquiringSDK
    }
    
    // MARK: - CardRemoveController
    
    func removeCard(_ cardId: String,
                    customerKey: String,
                    completion: @escaping (Result<RemoveCardPayload, Error>) -> Void) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            self.storeCardIdCompletion(cardId, completion: completion)
            
            if self.processes[cardId] == nil {
                let process = DefaultRemoveCardProcess(acquiringSDK: self.acquiringSDK,
                                                       customerKey: customerKey,
                                                       cardId: cardId)
                self.processes[cardId] = process
                process.delegate = self
                process.start()
            }
        }
    }
}

private extension DefaultRemoveCardController {
    func storeCardIdCompletion(_ cardId: String,
                               completion: @escaping (Result<RemoveCardPayload, Error>) -> Void) {
        var cardIdCompletions = completions[cardId] ?? []
        cardIdCompletions.append(completion)
        completions[cardId] = cardIdCompletions
    }
}

// MARK: - RemoveCardProcessDelegate

extension DefaultRemoveCardController: RemoveCardProcessDelegate {
    func removeCardProcessDidFinish(_ process: RemoveCardProcess,
                                    cardId: String,
                                    payload: RemoveCardPayload) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            self.completions[cardId]?.forEach { $0(.success(payload)) }
            self.processes[cardId] = nil
            self.completions[cardId] = nil
        }
    }
    
    func removeCardProccessDidFailed(_ process: RemoveCardProcess,
                                     cardId: String,
                                     error: Error) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            self.completions[cardId]?.forEach { $0(.failure(error)) }
            self.processes[cardId] = nil
            self.completions[cardId] = nil
        }
    }
}
