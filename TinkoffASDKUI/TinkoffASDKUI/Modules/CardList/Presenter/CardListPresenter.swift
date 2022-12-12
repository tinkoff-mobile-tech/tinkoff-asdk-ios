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

import TinkoffASDKCore
import UIKit

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
    private let bankResolver: IBankResolver
    private let paymentSystemResolver: IPaymentSystemResolver

    // MARK: State

    private var activeCardsCache: [PaymentCard] = []
    private var isEditingCards = true

    // MARK: Init

    init(
        imageResolver: IPaymentSystemImageResolver,
        provider: IPaymentCardsProvider,
        bankResolver: IBankResolver,
        paymentSystemResolver: IPaymentSystemResolver
    ) {
        self.imageResolver = imageResolver
        self.provider = provider
        self.bankResolver = bankResolver
        self.paymentSystemResolver = paymentSystemResolver
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
            let bank = bankResolver.resolve(cardNumber: card.pan).getBank()
            let cardModel = DynamicIconCardView.Model(
                data: DynamicIconCardView.Data(
                    bank: bank?.icon,
                    paymentSystem: paymentSystemResolver
                        .resolve(by: card.pan).getPaymentSystem()?.icon
                )
            )

            var bankText = bank?.naming ?? ""
            bankText = bankText.isEmpty ? bankText : bankText.appending(" ")
            let finalText = bankText + "· \(card.pan.suffix(4))"

            return CardList.Card(
                id: card.cardId,
                pan: .format(pan: card.pan),
                cardModel: cardModel,
                assembledText: finalText,
                isInEditingMode: isEditingCards
            )
        }
    }
}

// MARK: - ICardListViewOutput

extension CardListPresenter: ICardListViewOutput {

    func viewDidLoad() {
        performOnMain { [weak self] in
            self?.view?.showShimmer()
        }
        provider.fetchActiveCards { result in
            performOnMain { [weak self] in
                guard let self = self else { return }
                switch result {
                case let .success(paymentCards):
                    self.activeCardsCache = paymentCards
                    self.view?.reload(cards: self.transform(paymentCards))
                case .failure:
                    // swiftlint:disable wrong_todo_syntax
                    // TODO: Add failure handling
                    // swiftlint:enable wrong_todo_syntax
                    break
                }
                self.view?.hideShimmer()
            }
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
                // swiftlint:disable wrong_todo_syntax
                // TODO: Add failure handling
                // swiftlint:enable wrong_todo_syntax
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
