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
    var onSuccess: ((_ state: GetPaymentStatePayload, _ cardId: String?, _ rebillId: String?) -> Void)?
    var onFailed: ((Error) -> Void)?
    var needToCollect3DSData: ((Checking3DSURLData) -> DeviceInfoParams)?
    var need3DSConfirmation: ((Confirmation3DSData) -> GetPaymentStatePayload)?
    var need3DSConfirmationACS: ((Confirmation3DSDataACS) -> GetPaymentStatePayload)?
    
    private let acquiringSDK: AcquiringSdk
    private let paymentSource: PaymentSourceData
    private let paymentFlow: PaymentFlow
    private var isCancelled = Atomic(wrappedValue: false)
    private var currentRequest: Atomic<Cancellable>?
    
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
         paymentFlow: PaymentFlow) {
        self.acquiringSDK = acquiringSDK
        self.paymentSource = paymentSource
        self.paymentFlow = paymentFlow
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
                self.onFailed?(error)
            }
        }
        currentRequest?.store(newValue: request)
    }
    
    func check3DSVersion(paymentId: Int64) {
        let data = Check3DSRequestData(paymentId: paymentId,
                                       paymentSource: paymentSource)
        let request = acquiringSDK.check3dsVersion(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }
            
            switch result {
            case let .success(payload):
                self.handleCheck3DSResult(payload: payload, paymentId: paymentId)
            case let .failure(error):
                self.onFailed?(error)
            }
        }
        currentRequest?.store(newValue: request)
    }
    
    func finishPayment(data: PaymentFinishRequestData) {
        let request = acquiringSDK.paymentFinish(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }
            
            switch result {
            case let .success(payload):
                self.handlePaymentFinish(payload: payload)
            case let .failure(error):
                self.onFailed?(error)
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
            print("dsdsd")
        }
    }
    
    func handleCheck3DSResult(payload: Check3DSVersionPayload, paymentId: Int64) {
        var data = PaymentFinishRequestData(paymentId: paymentId,
                                            paymentSource: paymentSource)
        data.setInfoEmail(customerEmail)
        
        let performPaymentFinish: (PaymentFinishRequestData) -> Void = {
            self.finishPayment(data: $0)
        }
        
        if let tdsServerTransID = payload.tdsServerTransID,
           let threeDSMethodURL = payload.threeDSMethodURL {
            let check3DSData = Checking3DSURLData(tdsServerTransID: tdsServerTransID,
                                                  threeDSMethodURL: threeDSMethodURL)
            let deviceInfo = needToCollect3DSData?(check3DSData)
            data.setDeviceInfo(info: deviceInfo)
            data.setIpAddress(acquiringSDK.networkIpAddress()?.fullStringValue)
            data.setThreeDSVersion(payload.version)
            performPaymentFinish(data)
        } else {
            performPaymentFinish(data)
        }
    }
    
    func handlePaymentFinish(payload: FinishAuthorizePayload) {
        guard !self.isCancelled.wrappedValue else { return }
        
        let (cardId, rebillId) = getCardAndRebillId()
        
        switch payload.responseStatus {
        case .done:
            onSuccess?(payload.paymentState, cardId, rebillId)
        case let .needConfirmation3DS(data):
            if let paymentState = need3DSConfirmation?(data) {
                onSuccess?(paymentState, cardId, rebillId)
            }
        case let .needConfirmation3DSACS(data):
            if let paymentState = need3DSConfirmationACS?(data) {
                onSuccess?(paymentState, cardId, rebillId)
            }
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
