//
//
//  DefaultCardRemoveController.swift
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

final class DefaultCardRemoveController: CardRemoveController {
    
    // Dependencies
    
    private let acquiringSDK: AcquiringSdk
    
    // State
    
    private var processes = [String: RemoveCardProcess]()
    private var completions = [String: (Result<RemoveCardPayload, Error>) -> Void]()
    
    // MARK: - Init
    
    init(acquiringSDK: AcquiringSdk) {
        self.acquiringSDK = acquiringSDK
    }
    
    // MARK: - CardRemoveController
    
    func removeCard(_ cardId: String,
                    customerKey: String,
                    completion: @escaping (Result<RemoveCardPayload, Error>) -> Void) {
        DispatchQueue.safePerformOnMainQueueSync {
            self.cancelProccess(cardId: cardId)
            self.removeCompletion(cardId: cardId)
            
            let process = DefaultRemoveCardProcess(acquiringSDK: acquiringSDK,
                                                   customerKey: customerKey,
                                                   cardId: cardId)
            processes[cardId] = process
            completions[cardId] = completion
            process.delegate = self
            process.start()
        }
    }
}

extension DefaultCardRemoveController: RemoveCardProcessDelegate {
    func removeCardProcessDidFinish(_ process: RemoveCardProcess,
                                    cardId: String,
                                    payload: RemoveCardPayload) {
        DispatchQueue.safePerformOnMainQueueSync {
            guard let completion = completions[cardId] else { return }
            self.cancelProccess(cardId: cardId)
            self.removeCompletion(cardId: cardId)
            completion(.success(payload))
        }
    }
    
    func removeCardProccessDidFailed(_ process: RemoveCardProcess,
                                     cardId: String,
                                     error: Error) {
        DispatchQueue.safePerformOnMainQueueSync {
            guard let completion = completions[cardId] else { return }
            self.cancelProccess(cardId: cardId)
            self.removeCompletion(cardId: cardId)
            completion(.failure(error))
        }
    }
}

private extension DefaultCardRemoveController {
    func cancelProccess(cardId: String) {
        guard let cardIdPreviousProcess = processes[cardId] else {
            return
        }
        cardIdPreviousProcess.cancel()
        processes[cardId] = nil
    }
    
    func removeCompletion(cardId: String) {
        completions[cardId] = nil
    }
}
