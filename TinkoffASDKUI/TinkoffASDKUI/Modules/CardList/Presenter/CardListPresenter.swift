//
//
//  CardListPresenter.swift
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


import Foundation
import TinkoffASDKCore

protocol ICardListViewOutput: AnyObject {
    func viewDidLoad()
    func view(didSelect card: CardList.Card)
    func view(didTapDeleteOn card: CardList.Card)
    func viewDidTapPrimaryButton()
}

protocol ICardListModule: AnyObject {
    var onSelectCard: ((PaymentCard) -> Void)? { get set }
    var onAddNewCardTap: (() -> Void)? { get set }

    func addingNewCard(completedWith result: Result<PaymentCard?, Error>)
}

final class CardListPresenter: ICardListModule {
    // MARK: ICardListModule Event Handlers

    var onSelectCard: ((PaymentCard) -> Void)?
    var onAddNewCardTap: (() -> Void)?

    // MARK: Dependencies

    weak var view: ICardListViewInput?
    private let imageResolver: IPaymentSystemImageResolver
    private let provider: IPaymentCardsProvider

    // MARK: State

    private var activeCardsCache: [PaymentCard] = []

    // MARK: Init

    init(
        imageResolver: IPaymentSystemImageResolver,
        provider: IPaymentCardsProvider
    ) {
        self.imageResolver = imageResolver
        self.provider = provider
    }

    // MARK: ICardListModule Methods

    func addingNewCard(completedWith result: Result<PaymentCard?, Error>) {
        switch result {
        case let .success(card):
            // card == nil - добавление карты отменено пользователем
            if let card = card {
                activeCardsCache.append(card)
                view?.reload(cards: transform(activeCardsCache))
                view?.show(alert: .cardAdded(card: card))
            }
        case let .failure(error):
            view?.show(alert: .cardAddingFailed(with: error))
        }
    }

    // MARK: Helpers

    private func transform(_ paymentCards: [PaymentCard]) -> [CardList.Card] {
        paymentCards.map { card in
            CardList.Card(
                id: card.cardId,
                pan: .format(pan: card.pan),
                validThru: .format(validThru: card.expDate),
                icon: imageResolver.resolve(by: card.pan)
            )
        }
    }
}

// MARK: - ICardListViewOutput

extension CardListPresenter: ICardListViewOutput {
    func viewDidLoad() {
        view?.showLoader()
        provider.fetchActiveCards { [self] result in
            switch result {
            case let .success(paymentCards):
                activeCardsCache = paymentCards
                view?.reload(cards: transform(paymentCards))
            case .failure:
                // TODO: Add failure handling
                break
            }

            view?.hideLoader()
        }
    }

    func view(didSelect card: CardList.Card) {
        guard let paymentCard = activeCardsCache.first(where: { $0.cardId == card.id }) else {
            return
        }
        onSelectCard?(paymentCard)
    }

    func view(didTapDeleteOn card: CardList.Card) {
        view?.showLoader()

        provider.deactivateCard(cardId: card.id) { [self] result in
            switch result {
            case .success:
                activeCardsCache.removeAll { $0.cardId == card.id }
                view?.remove(card: card)
            case .failure:
                // TODO: Add failure handling
                break
            }
            view?.hideLoader()
        }
    }

    func viewDidTapPrimaryButton() {
        onAddNewCardTap?()
    }
}

// MARK: - String + Helpers

private extension String {
    static func format(pan: String) -> String {
        "*" + pan.suffix(4)
    }

    static func format(validThru: String?) -> String {
        validThru.map { $0.prefix(2) + "/" + $0.suffix(2) } ?? ""
    }
}
