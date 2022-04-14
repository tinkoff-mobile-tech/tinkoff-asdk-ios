//
//  AcquiringPaymentController.swift
//  Pods-ASDKSample
//
//  Created by Serebryaniy Grigoriy on 14.04.2022.
//

import TinkoffASDKCore

protocol AcquiringPaymentControllerDelegate: AnyObject {
    func acquiringPaymentController(_ acquiringPaymentController: AcquiringPaymentController,
                                    didUpdateCards status: FetchStatus<[PaymentCard]>)
    func acquiringPaymentController(_ acquiringPaymentController: AcquiringPaymentController,
                                    didUpdateTinkoffPayAvailability status: GetTinkoffPayStatusResponse.Status)
    func acquiringPaymentControllerDidFinishPreparation(_ acquiringPaymentController: AcquiringPaymentController)
}

final class AcquiringPaymentController {
    private let acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration
    private let tinkoffPayController: TinkoffPayController
    private let cardListDataProvider: CardListDataProvider?
    
    weak var delegate: AcquiringPaymentControllerDelegate?
    
    init(acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
         tinkoffPayController: TinkoffPayController,
         cardListDataProvider: CardListDataProvider?) {
        self.acquiringPaymentStageConfiguration = acquiringPaymentStageConfiguration
        self.tinkoffPayController = tinkoffPayController
        self.cardListDataProvider = cardListDataProvider
    }
    
    func loadCardsAndCheckTinkoffPayAvailability() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        _ = tinkoffPayController.checkIfTinkoffPayAvailable { [weak self] result in
            self?.handleTinkoffPayAvailabilityCheck(result: result)
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        cardListDataProvider?.fetch(startHandler: nil, completeHandler: { [weak self] _, _ in
            self?.handleCardsFetch()
            dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.delegate?.acquiringPaymentControllerDidFinishPreparation(self)
        }
    }
    
    func performTinkoffPayPayment() {
        switch acquiringPaymentStageConfiguration.paymentStage {
        case let .`init`(paymentData):
            self.initPayment(paymentData: paymentData)
        case let .finish(paymentId):
            self.finishPayment(paymentId: paymentId)
        }
    }
}

private extension AcquiringPaymentController {
    func handleTinkoffPayAvailabilityCheck(result: Result<GetTinkoffPayStatusResponse.Status, Error>) {
        switch result {
        case .failure(_):
            delegate?.acquiringPaymentController(self,
                                                 didUpdateTinkoffPayAvailability: .disallowed)
        case let .success(status):
            delegate?.acquiringPaymentController(self,
                                                 didUpdateTinkoffPayAvailability: status)
        }
    }
    
    func handleCardsFetch() {
        guard let status = cardListDataProvider?.fetchStatus else { return }
        delegate?.acquiringPaymentController(self, didUpdateCards: status)
    }
    
    func initPayment(paymentData: PaymentInitData) {
        
    }
    
    func finishPayment(paymentId: Int64) {
        
    }
}
