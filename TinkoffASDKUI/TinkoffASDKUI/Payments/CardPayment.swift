//
//
//  CardPayment.swift
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

final class CardPayment: Payment {
    private let acquiringSDK: AcquiringSdk
    private let paymentSource: PaymentSourceData
    private let paymentFlow: PaymentFlow
    private var isCancelled = Atomic(wrappedValue: false)
    private var currentRequest: Atomic<Cancellable>?
    
    private(set) var paymentId: PaymentId?
    
    private weak var delegate: PaymentDelegate?
    
    private var customerEmail: String? {
        switch paymentFlow {
        case let .full(paymentOptions):
            return paymentOptions.customerOptions.email
        case let .finish(_, customerOptions):
            return customerOptions.email
        }
    }
    
    init(acquiringSDK: AcquiringSdk,
         paymentSource: PaymentSourceData,
         paymentFlow: PaymentFlow,
         delegate: PaymentDelegate) {
        self.acquiringSDK = acquiringSDK
        self.paymentSource = paymentSource
        self.paymentFlow = paymentFlow
        self.delegate = delegate
    }
    
    func start() {
        switch paymentFlow {
        case let .full(paymentOptions):
            initPayment(data: PaymentInitData.data(with: paymentOptions))
        case let .finish(paymentId, _):
            check3DSVersion(paymentId: paymentId)
        }
    }
    
    func cancel() {
        isCancelled.store(newValue: true)
        currentRequest?.wrappedValue.cancel()
    }
}

private extension CardPayment {
    func initPayment(data: PaymentInitData) {
        let request = acquiringSDK.paymentInit(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }
            
            switch result {
            case let .success(payload):
                self.handleInitResult(payload: payload)
            case let .failure(error):
                self.delegate?.paymentDidFailed(self, with: error)
            }
        }
        currentRequest?.store(newValue: request)
    }
    
    func check3DSVersion(paymentId: Int64) {
        self.paymentId = paymentId
        
        let data = Check3DSRequestData(paymentId: paymentId,
                                       paymentSource: paymentSource)
        let request = acquiringSDK.check3dsVersion(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }
            
            switch result {
            case let .success(payload):
                self.handleCheck3DSResult(payload: payload, paymentId: paymentId)
            case let .failure(error):
                self.delegate?.paymentDidFailed(self, with: error)
            }
        }
        currentRequest?.store(newValue: request)
    }
    
    func finishPayment(data: PaymentFinishRequestData, threeDSVersion: String? = nil) {
        let request = acquiringSDK.paymentFinish(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }
            
            switch result {
            case let .success(payload):
                self.handlePaymentFinish(payload: payload, threeDSVersion: threeDSVersion)
            case let .failure(error):
                self.delegate?.paymentDidFailed(self, with: error)
            }
        }
        currentRequest?.store(newValue: request)
    }
    
    func handleInitResult(payload: InitPayload) {
        switch paymentSource {
        case .cardNumber, .savedCard:
            self.check3DSVersion(paymentId: payload.paymentId)
        case .paymentData:
            var data = PaymentFinishRequestData(paymentId: payload.paymentId,
                                                paymentSource: paymentSource)
            data.setInfoEmail(customerEmail)
            self.finishPayment(data: data)
        default:
        // TODO: Log error
        print("Only cardNumber, savedCard or paymentData PaymentSourceData available")
        }
    }
    
    func handleCheck3DSResult(payload: Check3DSVersionPayload, paymentId: Int64) {
        var data = PaymentFinishRequestData(paymentId: paymentId,
                                            paymentSource: paymentSource)
        data.setInfoEmail(customerEmail)
        
        let performPaymentFinish: (PaymentFinishRequestData) -> Void = {
            self.finishPayment(data: $0, threeDSVersion: payload.version)
        }
        
        if let tdsServerTransID = payload.tdsServerTransID,
           let threeDSMethodURL = payload.threeDSMethodURL {
            let check3DSData = Checking3DSURLData(tdsServerTransID: tdsServerTransID,
                                                  threeDSMethodURL: threeDSMethodURL)
            self.delegate?.payment(
                self,
                needToCollect3DSData: check3DSData,
                completion: {[weak self] deviceInfo in
                    guard let self = self else { return }
                    data.setDeviceInfo(info: deviceInfo)
                    data.setIpAddress(self.acquiringSDK.networkIpAddress()?.fullStringValue)
                    data.setThreeDSVersion(payload.version)
                    performPaymentFinish(data)
                }
            )
        } else {
            performPaymentFinish(data)
        }
    }
    
    func handlePaymentFinish(payload: FinishAuthorizePayload, threeDSVersion: String?) {
        guard !self.isCancelled.wrappedValue else { return }
        
        switch payload.responseStatus {
        case .success:
            self.handlePaymentResult(.success(payload.paymentState))
        case let .needConfirmation3DS(data):
            delegate?.payment(self,
                              need3DSConfirmation: data,
                              confirmationCancelled: { [weak self] in
                                self?.handlePaymentCancelled(payload: payload)
                              },
                              completion: { [weak self] result in
                                self?.handlePaymentResult(result)
                              })
        case let .needConfirmation3DSACS(data):
            delegate?.payment(self,
                              need3DSConfirmationACS: data,
                              version: threeDSVersion,
                              confirmationCancelled: { [weak self] in
                                self?.handlePaymentCancelled(payload: payload)
                              },
                              completion: { [weak self] result in
                                self?.handlePaymentResult(result)
                              })
        }
    }
    
    func handlePaymentCancelled(payload: FinishAuthorizePayload) {
        let cancelledState = GetPaymentStatePayload(paymentId: payload.paymentState.paymentId,
                                                    amount: payload.paymentState.amount,
                                                    orderId: payload.paymentState.orderId,
                                                    status: .cancelled)
        self.handlePaymentResult(.success(cancelledState))
    }
    
    func handlePaymentResult(_ result: Result<GetPaymentStatePayload, Error>) {
        let (cardId, rebillId) = getCardAndRebillId()
        
        switch result {
        case let .success(payload):
            delegate?.paymentDidFinish(self,
                                       with: payload,
                                       cardId: cardId,
                                       rebillId: rebillId)
        case let .failure(error):
            delegate?.paymentDidFailed(self, with: error)
        }
    }
    
    func getCardAndRebillId() -> (cardId: String?, rebillId: String?) {
        switch paymentSource {
        case .parentPayment(let rebillId):
            return (nil, rebillId)
        case .savedCard(let cardId, _):
            return (cardId, nil)
        default:
            return (nil, nil)
        }
    }
}
