//
//  CardsController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 16.02.2023.
//

import Foundation
import TinkoffASDKCore

final class CardsController {
    // MARK: Error

    enum Error: Swift.Error {
        case missingCardId
        case couldNotFindAddedCard
    }

    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let addCardController: IAddCardController
    private let customerKey: String
    private let availableCardStatuses: Set<PaymentCardStatus>

    // MARK: Init

    init(
        coreSDK: AcquiringSdk,
        addCardController: IAddCardController,
        customerKey: String,
        availableCardStatuses: Set<PaymentCardStatus> = [.active]

    ) {
        self.coreSDK = coreSDK
        self.addCardController = addCardController
        self.customerKey = customerKey
        self.availableCardStatuses = availableCardStatuses
    }
}

// MARK: - ICardsController

extension CardsController: ICardsController {
    var uiProvider: PaymentControllerUIProvider? {
        get { addCardController.uiProvider }
        set { addCardController.uiProvider = newValue }
    }

    func addCard(options: AddCardOptions, completion: @escaping (AddNewCardResult) -> Void) {
        let completionDecorator: (AddNewCardResult) -> Void = { result in
            DispatchQueue.performOnMain { completion(result) }
        }

        addCardController.addCard(options: options) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .succeded(payload):
                self.resolveAddedCard(payload: payload, completion: completionDecorator)
            case let .failed(error):
                completionDecorator(.failure(error: error))
            case .cancelled:
                completionDecorator(.cancelled)
            }
        }
    }

    func removeCard(cardId: String, completion: @escaping (Result<RemoveCardPayload, Swift.Error>) -> Void) {
        let data = RemoveCardData(cardId: cardId, customerKey: customerKey)

        coreSDK.removeCard(data: data) { result in
            DispatchQueue.performOnMain { completion(result) }
        }
    }

    func getCards(completion: @escaping (Result<[PaymentCard], Swift.Error>) -> Void) {
        let getCardListData = GetCardListData(customerKey: customerKey)

        coreSDK.getCardList(data: getCardListData) { [availableCardStatuses] result in
            let filteredCardsResult = result.map { cards in
                cards.filter { availableCardStatuses.contains($0.status) }
            }

            DispatchQueue.performOnMain { completion(filteredCardsResult) }
        }
    }
}

// MARK: - Helpers

extension CardsController {
    private func resolveAddedCard(payload: GetAddCardStatePayload, completion: @escaping (AddNewCardResult) -> Void) {
        guard let cardId = payload.cardId else {
            return completion(.failure(error: Error.missingCardId))
        }

        getCards { result in
            switch result {
            case let .success(cards):
                guard let addedCard = cards.first(where: { $0.cardId == cardId }) else {
                    return completion(.failure(error: Error.couldNotFindAddedCard))
                }
                completion(.success(card: addedCard))
            case let .failure(error):
                completion(.failure(error: error))
            }
        }
    }
}
