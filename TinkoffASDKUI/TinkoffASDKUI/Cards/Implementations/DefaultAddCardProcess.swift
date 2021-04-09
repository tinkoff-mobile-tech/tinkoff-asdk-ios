//
//
//  DefaultAddCardProcess.swift
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

final class DefaultAddCardProcess: AddCardProcess {

    // Dependencies
    
    private let acquiringSDK: AcquiringSdk
    private let customerKey: String
    private let cardData: CardData
    private let checkType: PaymentCardCheckType
    
    weak var delegate: AddCardProcessDelegate?
    
    // State
    
    private var isCancelled = Atomic(wrappedValue: false)
    private var currentRequest: Atomic<Cancellable>?
    private var timer: DispatchSourceTimer?
    
    // MARK: - Init
    
    init(acquiringSDK: AcquiringSdk,
         customerKey: String,
         cardData: CardData,
         checkType: PaymentCardCheckType) {
        self.acquiringSDK = acquiringSDK
        self.customerKey = customerKey
        self.cardData = cardData
        self.checkType = checkType
    }
    
    // MARK: - AddCardProcess
    
    func start() {
        initCardAddition(cardData: cardData, checkType: checkType)
    }

    func cancel() {
        isCancelled.store(newValue: true)
        currentRequest?.wrappedValue.cancel()
        timer?.cancel()
    }
}

private extension DefaultAddCardProcess {
    func initCardAddition(cardData: CardData, checkType: PaymentCardCheckType) {
        let data = InitAddCardData(with: checkType.rawValue, customerKey: customerKey)
        let request = acquiringSDK.addCardInit(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }
            
            switch result {
            case let .success(payload):
                self.finishCardAddition(cardData: cardData, requestKey: payload.requestKey)
            case let .failure(error):
                self.delegate?.addCardProcessDidFailed(self, error: error)
            }
        }
        currentRequest?.store(newValue: request)
    }
    
    func finishCardAddition(cardData: CardData, requestKey: String) {
        let data = FinishAddCardData(cardData: cardData, requestKey: requestKey)
        let request = acquiringSDK.addCardFinish(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }
            
            switch result {
            case let .success(payload):
                self.handleFinishResult(payload: payload)
            case let .failure(error):
                self.delegate?.addCardProcessDidFailed(self, error: error)
            }
        }
        
        currentRequest?.store(newValue: request)
    }
    
    func handleFinishResult(payload: AttachCardPayload) {
        guard !isCancelled.wrappedValue else { return }
        
        let confirmationCancelled: () -> Void = { [weak self] in
            self?.handleAdditionCancelled(payload: payload)
        }
        
        let completion: (Result<Void, Error>) -> Void = { [weak self] result in
            self?.handleConfirmationResult(requestKey: payload.requestKey, result)
        }

        switch payload.attachCardStatus {
        case .done:
            let state = GetAddCardStatePayload(requestKey: payload.requestKey,
                                               status: payload.status,
                                               customerKey: customerKey,
                                               cardId: payload.cardId,
                                               rebillId: payload.rebillId)
            delegate?.addCardProcessDidFinish(self, state: state)
        case let .needConfirmation3DS(data):
            delegate?.addCardProcess(self,
                                     need3DSConfirmation: data,
                                     confirmationCancelled: confirmationCancelled,
                                     completion: completion)
        case let .needConfirmation3DSACS(data):
            delegate?.addCardProcess(self,
                                     need3DSConfirmationACS: data,
                                     confirmationCancelled: confirmationCancelled,
                                     completion: completion)
        case let .needConfirmationRandomAmount(requestKey):
            delegate?.addCardProcess(self,
                                     needRandomAmountConfirmation: requestKey,
                                     confirmationCancelled: confirmationCancelled,
                                     completion: completion)
        }
    }
    
    func handleAdditionCancelled(payload: AttachCardPayload) {
        delegate?.addCardProcessDidFinish(self, state: .init(requestKey: payload.requestKey,
                                                             status: .cancelled,
                                                             customerKey: customerKey,
                                                             cardId: payload.cardId,
                                                             rebillId: payload.rebillId))
    }
    
    func handleConfirmationResult(requestKey: String, _ result: Result<Void, Error>) {
        switch result {
        case .success:
            startAddCardCheck(requestKey: requestKey)
        case let .failure(error):
            delegate?.addCardProcessDidFailed(self, error: error)
        }
    }
    
    func startAddCardCheck(requestKey: String) {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: .seconds(5))
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            let request = self.acquiringSDK.getAddCardState(data: .init(requestKey: requestKey), completionHandler: { [weak self] result in
                guard let self = self else { return }
                guard case let .success(payload) = result else { return }
                timer.cancel()
                self.delegate?.addCardProcessDidFinish(self, state: payload)
            })
            self.currentRequest?.store(newValue: request)
        }
        timer.resume()
    }
}
