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
        case couldNotFindAddedCard(cardId: String)
    }

    // MARK: Dependencies

    private let cardService: ICardService
    private let addCardController: IAddCardController

    // MARK: Init

    init(
        cardService: ICardService,
        addCardController: IAddCardController
    ) {
        self.cardService = cardService
        self.addCardController = addCardController
    }
}

// MARK: - ICardsController

extension CardsController: ICardsController {
    var webFlowDelegate: ThreeDSWebFlowDelegate? {
        get { addCardController.webFlowDelegate }
        set { addCardController.webFlowDelegate = newValue }
    }

    var customerKey: String { addCardController.customerKey }

    func addCard(options: CardOptions, completion: @escaping (AddCardResult) -> Void) {
        let completionDecorator: (AddCardResult) -> Void = { result in
            DispatchQueue.performOnMain { completion(result) }
        }

        addCardController.addCard(options: options) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .succeded(payload):
                self.resolveAddedCard(payload: payload, completion: completionDecorator)
            case let .failed(error):
                completionDecorator(.failed(error))
            case .cancelled:
                completionDecorator(.cancelled)
            }
        }
    }

    func removeCard(cardId: String, completion: @escaping (Result<RemoveCardPayload, Swift.Error>) -> Void) {
        let data = RemoveCardData(cardId: cardId, customerKey: customerKey)

        cardService.removeCard(data: data) { result in
            DispatchQueue.performOnMain { completion(result) }
        }
    }

    func getActiveCards(completion: @escaping (Result<[PaymentCard], Swift.Error>) -> Void) {
        let getCardListData = GetCardListData(customerKey: customerKey)

        cardService.getCardList(data: getCardListData) { result in
            let filteredCardsResult = result.map { cards in
                cards.filter { $0.status == .active }
            }

            DispatchQueue.performOnMain { completion(filteredCardsResult) }
        }
    }
}

// MARK: - Helpers

extension CardsController {
    private func resolveAddedCard(payload: GetAddCardStatePayload, completion: @escaping (AddCardResult) -> Void) {
        guard let cardId = payload.cardId else {
            return completion(.failed(Error.missingCardId))
        }

        getActiveCards { result in
            switch result {
            case let .success(cards):
                guard let addedCard = cards.first(where: { $0.cardId == cardId }) else {
                    return completion(.failed(Error.couldNotFindAddedCard(cardId: cardId)))
                }
                completion(.succeded(addedCard))
            case let .failure(error):
                completion(.failed(error))
            }
        }
    }
}

// MARK: - CardsController.Error + LocalizedError

extension CardsController.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingCardId:
            return "Unexpected nil for `cardId` after adding new card"
        case let .couldNotFindAddedCard(cardId):
            return "Unexpected behavior of Acquiring API. Could not find added card with id \(cardId) in `GetCardList` response"
        }
    }
}
