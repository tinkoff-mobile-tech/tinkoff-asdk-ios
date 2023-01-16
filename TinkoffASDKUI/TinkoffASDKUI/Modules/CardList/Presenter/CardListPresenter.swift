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

protocol ICardListViewOutput: AnyObject, IAddNewCardOutput {
    func viewDidLoad()
    func view(didTapDeleteOn card: CardList.Card)
    func viewDidTapEditButton()
    func viewDidTapDoneEditingButton()
    func viewDidHideLoadingSnackbar()
    func viewDidTapCard(cardIndex: Int)
    func viewDidTapAddCardCell()
    func viewDidHideShimmer(fetchCardsResult: Result<[PaymentCard], Error>)
    func viewDidShowAddedCardSnackbar()
}

protocol ICardListModule: AnyObject {
    var onSelectCard: ((PaymentCard) -> Void)? { get set }
    var onAddNewCardTap: (() -> Void)? { get set }
}

enum CardListScreenState {
    case initial
    case showingCards
    case editingCards
    case showingStub
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
    private var isLoading = false
    private var hasVisualContent: Bool { !activeCardsCache.isEmpty }
    private var screenState = CardListScreenState.initial
    private var deactivateCardResult: Result<Void, Error>?
    private var sections: [CardListSection] { getSections() }

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

            let bankText = bank?.naming ?? ""
            var cardNumberText = String.format(pan: card.pan)
            cardNumberText = bankText.isEmpty ? cardNumberText : (" " + cardNumberText)

            return CardList.Card(
                id: card.cardId,
                pan: .format(pan: card.pan),
                cardModel: cardModel,
                bankNameText: bankText,
                cardNumberText: cardNumberText,
                isInEditingMode: screenState == .editingCards
            )
        }
    }
}

// MARK: - ICardListViewOutput

extension CardListPresenter: ICardListViewOutput {

    func viewDidLoad() {
        view?.showShimmer()
        fetchActiveCards()
    }

    func viewDidTapCard(cardIndex: Int) {
        onSelectCard?(activeCardsCache[cardIndex])
    }

    func viewDidTapAddCardCell() {
        onAddNewCardTap?()
    }

    func viewDidHideShimmer(fetchCardsResult: Result<[PaymentCard], Error>) {
        handleFetchedActiveCard(result: fetchCardsResult)
    }

    func viewDidShowAddedCardSnackbar() {
        reloadCollection()
    }

    func viewDidShowAddedCardSnackbar() {
        reloadCollection()
    }

    func view(didTapDeleteOn card: CardList.Card) {
        isLoading = true
        view?.disableViewUserInteraction()
        view?.showLoadingSnackbar(
            text: Loc.Acquiring.CardList.deleteSnackBar + " " + card.pan
        )

        provider.deactivateCard(cardId: card.id) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.deactivateCardResult = result
            self.view?.hideLoadingSnackbar()
        }
    }

    func viewDidTapEditButton() {
        guard screenState == .showingCards, !isLoading else { return }
        screenState = .editingCards
        view?.showDoneEditingButton()
        reloadCollection()
    }

    func viewDidTapDoneEditingButton() {
        guard !isLoading else { return }
        screenState = .showingCards
        view?.showEditButton()
        reloadCollection()
    }

    func viewDidHideLoadingSnackbar() {
        if let result = deactivateCardResult {
            deactivateCardResult = nil

            switch result {
            case .success:
                fetchActiveCards()
            case .failure:
                if hasVisualContent {
                    showRemoveCardErrorAlert()
                }
            }
        }

        view?.enableViewUserInteraction()
    }
}

extension CardListPresenter: IAddNewCardOutput {

    func addingNewCardCompleted(result: AddNewCardResult) {
        switch result {
        case .cancelled, .failure:
            break
        case let .success(card):
            screenState = .showingCards
            activeCardsCache.append(card)
            view?.showAddedCardSnackbar(cardMaskedPan: String.format(pan: card.pan))
        }
    }
}

extension CardListPresenter {

    // MARK: - Private

    private func fetchActiveCards() {
        isLoading = true
        provider.fetchActiveCards { [weak self] result in
            self?.isLoading = false
            self?.view?.hideShimmer(fetchCardsResult: result)
        }
    }

    private func handleFetchedActiveCard(result: Result<[PaymentCard], Error>) {
        isLoading = false

        switch result {
        case let .success(paymentCards):
            activeCardsCache = paymentCards
            if paymentCards.isEmpty {
                viewDidTapDoneEditingButton()
                reloadCollection()
                showNoCardsStub()
            } else {
                if screenState != .editingCards {
                    screenState = .showingCards
                }
                reloadCollection()
            }

        case let .failure(error):
            switch (error as NSError).code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorDataNotAllowed:
                showNoNetworkStub()
            default:
                showServerErrorStub()
            }
        }

        view?.enableViewUserInteraction()
    }

    private func showServerErrorStub() {
        screenState = .showingStub
        view?.hideRightBarButton()
        view?.showStub(mode: .serverError { [weak self] in
            self?.view?.dismiss()
        })
    }

    private func showNoNetworkStub() {
        screenState = .showingStub
        view?.hideRightBarButton()
        view?.showStub(mode: .noNetwork { [weak self] in
            self?.view?.hideStub()
            self?.viewDidLoad()
        })
    }

    private func showNoCardsStub() {
        screenState = .showingStub
        view?.hideRightBarButton()
        view?.showStub(mode: .noCards { [weak self] in
            self?.onAddNewCardTap?()
        })
    }

    private func reloadCollection() {
        showBarButton()
        view?.hideStub()
        view?.reload(sections: sections)
    }

    private func showBarButton() {
        screenState == .editingCards
            ? view?.showDoneEditingButton()
            : view?.showEditButton()
    }

    private func showRemoveCardErrorAlert() {
        view?.showNativeAlert(
            data: OkAlertData(
                title: Loc.CommonAlert.DeleteCard.title,
                buttonTitle: Loc.CommonAlert.button
            )
        )
    }

    private func getSections() -> [CardListSection] {
        var result: [CardListSection] = [
            .cards(data: transform(activeCardsCache)),
        ]

        if screenState != .editingCards {
            result.append(.addCard(data: prepareAddCardConfigs()))
        }
        return result
    }

    private func prepareAddCardConfigs() -> [(ImageAsset, String)] {
        return [
            (icon: Asset.Icons.addCard, title: Loc.Acquiring.CardList.addCard),
        ]
    }
}

// MARK: - String + Helpers

private extension String {
    static func format(pan: String) -> String {
        "• " + pan.suffix(4)
    }

    static func format(validThru: String?) -> String {
        validThru.map { $0.prefix(2) + "/" + $0.suffix(2) } ?? ""
    }
}
