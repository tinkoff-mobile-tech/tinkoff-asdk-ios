//
//  AcquiringPaymentController.swift
//  Pods-ASDKSample
//
//  Created by Serebryaniy Grigoriy on 14.04.2022.
//

import Foundation
import TinkoffASDKCore

protocol AcquiringPaymentControllerDelegate: AnyObject {
    func acquiringPaymentController(
        _ acquiringPaymentController: AcquiringPaymentController,
        didUpdateCards status: FetchStatus<[PaymentCard]>
    )
    func acquiringPaymentController(
        _ acquiringPaymentController: AcquiringPaymentController,
        didUpdateTinkoffPayAvailability status: GetTinkoffPayStatusResponse.Status
    )
    func acquiringPaymentControllerDidFinishPreparation(_ acquiringPaymentController: AcquiringPaymentController)
    func acquiringPaymentController(
        _ acquiringPaymentController: AcquiringPaymentController,
        didPaymentInitWith result: Result<Int64, Error>
    )
}

final class AcquiringPaymentController {
    private let acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration
    private let tinkoffPayController: TinkoffPayController
    private let payController: PayController
    private let cardsManager: CardsManager

    weak var delegate: AcquiringPaymentControllerDelegate?
    weak var tinkoffPayDelegate: TinkoffPayDelegate?

    init(
        acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
        tinkoffPayController: TinkoffPayController,
        payController: PayController,
        cardsManager: CardsManager
    ) {
        self.acquiringPaymentStageConfiguration = acquiringPaymentStageConfiguration
        self.tinkoffPayController = tinkoffPayController
        self.payController = payController
        self.cardsManager = cardsManager
    }

    func loadCardsAndCheckTinkoffPayAvailability() {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        _ = tinkoffPayController.checkIfTinkoffPayAvailable { [weak self] result in
            self?.handleTinkoffPayAvailabilityCheck(result: result)
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        cardsManager.getCards { [weak self] _ in
            self?.handleCardsFetch()
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.delegate?.acquiringPaymentControllerDidFinishPreparation(self)
        }
    }

    func performPayment() {
        switch acquiringPaymentStageConfiguration.paymentStage {
        case let .`init`(paymentData):
            payController.initPayment(with: paymentData) { [weak self] result in
                guard let self = self else { return }
                self.delegate?.acquiringPaymentController(
                    self,
                    didPaymentInitWith: result
                )
            }
        case let .finish(paymentId):
            delegate?.acquiringPaymentController(
                self,
                didPaymentInitWith: .success(paymentId)
            )
        }
    }
}

private extension AcquiringPaymentController {
    func handleTinkoffPayAvailabilityCheck(result: Result<GetTinkoffPayStatusResponse.Status, Error>) {
        switch result {
        case .failure:
            tinkoffPayDelegate?.tinkoffPayIsNotAllowed()
            delegate?.acquiringPaymentController(
                self,
                didUpdateTinkoffPayAvailability: .disallowed
            )
        case let .success(status):
            delegate?.acquiringPaymentController(
                self,
                didUpdateTinkoffPayAvailability: status
            )
        }
    }

    func handleCardsFetch() {
        let status = cardsManager.getCardsListFetchStatus()
        delegate?.acquiringPaymentController(self, didUpdateCards: status)
    }
}
