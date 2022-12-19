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
    func view(didTapDeleteOn card: CardList.Card)
    func viewDidTapPrimaryButton()
    func viewDidTapEditButton()
    func viewDidTapDoneEditingButton()
    func viewNativeAlertDidTapButton()
    func viewDidHideLoadingSnackbar()
    func viewDidTapCard(cardIndex: Int)
    func viewDidTapAddCardCell()
    func viewDidHideShimmer()

    // collection data source

    func viewNumberOfSections() -> Int
    func viewNumberOfItems(forSection: CardListSection) -> Int
    func viewCellModel<Model>(section: CardListSection, itemIndex: Int) -> Model?
}

protocol ICardListModule: AnyObject {
    var onSelectCard: ((PaymentCard) -> Void)? { get set }
    var onAddNewCardTap: (() -> Void)? { get set }

    func addingNewCard(completedWith result: Result<PaymentCard?, Error>)
}

enum CardListScreenState {
    case initial
    case loading
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
    private var fetchActiveCardsResult: Result<[PaymentCard], Error>?
    private var deactivateCardResult: (() -> Result<Void, Error>)?

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
                showCards(cards: activeCardsCache)
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
                isInEditingMode: screenState == .editingCards
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
        fetchActiveCards()
    }

    func viewDidTapCard(cardIndex: Int) {
        onSelectCard?(activeCardsCache[cardIndex])
    }

    func viewDidTapAddCardCell() {
        onAddNewCardTap?()
    }

    func viewDidHideShimmer() {
        guard let result = fetchActiveCardsResult else { return }
        handleFetchedActiveCard(result: result)
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
            self.deactivateCardResult = { result }
            self.view?.hideLoadingSnackbar()
        }
    }

    func viewDidTapPrimaryButton() {
        onAddNewCardTap?()
    }

    func viewDidTapEditButton() {
        guard screenState == .showingCards, !isLoading else { return }
        view?.showDoneEditingButton()
        showCards(cards: activeCardsCache, screenState: .editingCards)
    }

    func viewDidTapDoneEditingButton() {
        guard !isLoading else { return }
        view?.showEditButton()
        showCards(cards: activeCardsCache)
    }

    func viewNativeAlertDidTapButton() {
        view?.dismissAlert()
    }

    func viewDidHideLoadingSnackbar() {
        if let result = deactivateCardResult?() {
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

    // collection data source

    func viewNumberOfSections() -> Int {
        switch screenState {
        case .showingCards:
            return CardListSection.allCases.count
        case .editingCards:
            return CardListSection.allCases.count - 1
        default:
            return .zero
        }
    }

    func viewNumberOfItems(forSection: CardListSection) -> Int {
        switch forSection {
        case .cards:
            return activeCardsCache.count
        case .addCard:
            return 1
        }
    }

    func viewCellModel<Model>(section: CardListSection, itemIndex: Int) -> Model? {
        switch section {
        case .cards:
            return transform(activeCardsCache)[itemIndex] as? Model

        case .addCard:
            let configuration = IconTitleView.Configuration.buildAddCardButton(
                icon: Asset.Icons.addCard.image,
                text: Loc.Acquiring.CardList.addCard
            )

            return configuration as? Model
        }
    }
}

extension CardListPresenter {

    // MARK: - For testing only funcs

    func setScreenState(_ state: CardListScreenState) {
        screenState = state
    }

    func setActiveCardsCache(_ cards: [PaymentCard]) {
        activeCardsCache = cards
    }

    func setFetchedActiveCardsResult(_ result: Result<[PaymentCard], Error>?) {
        fetchActiveCardsResult = result
    }

    func setDeactivateCardResult(_ result: Result<Void, Error>) {
        deactivateCardResult = { result }
    }

    // MARK: - Private

    private func fetchActiveCards() {
        screenState = .loading
        isLoading = true
        provider.fetchActiveCards { result in
            performOnMain { [weak self] in
                self?.fetchActiveCardsResult = result
                self?.view?.hideShimmer()
            }
        }
    }

    private func handleFetchedActiveCard(result: Result<[PaymentCard], Error>) {
        isLoading = false

        switch result {
        case let .success(paymentCards):
            activeCardsCache = paymentCards
            if paymentCards.isEmpty {
                viewDidTapDoneEditingButton()
                showCards(cards: [])
                showNoCardsStub()
            } else {
                showCards(cards: activeCardsCache)
            }

        case let .failure(error):
            switch (error as NSError).code {
            case NSURLErrorNotConnectedToInternet:
                showNoNetworkStub()
            default:
                showServerErrorStub()
            }
        }
    }

    private func showStub(mode: StubMode) {
        screenState = .showingStub
        view?.hideStub()
        view?.showStub(mode: mode)
    }

    private func showServerErrorStub() {
        let mode = StubMode.serverError { [weak self] in self?.didTapServerErrorStubButton() }
        showStub(mode: mode)
    }

    private func showNoNetworkStub() {
        let mode = StubMode.noNetwork { [weak self] in self?.didTapNoNetworkStubButton() }
        showStub(mode: mode)
    }

    private func showNoCardsStub() {
        let mode = StubMode.noCards { [weak self] in self?.didTapNoCardsStubButton() }
        showStub(mode: mode)
    }

    private func didTapServerErrorStubButton() {
        view?.dismiss()
    }

    private func didTapNoCardsStubButton() {
        view?.addCard()
    }

    private func didTapNoNetworkStubButton() {
        view?.hideStub()
        viewDidLoad()
    }

    private func showCards(
        cards: [PaymentCard],
        screenState: CardListScreenState = .showingCards
    ) {
        self.screenState = screenState
        view?.hideStub()
        view?.reload(cards: transform(cards))
    }

    private func showRemoveCardErrorAlert() {
        view?.showNativeAlert(
            title: Loc.CommonAlert.DeleteCard.title,
            message: nil,
            buttonTitle: Loc.CommonAlert.button
        )
    }
}

// MARK: - String + Helpers

private extension String {
    static func format(pan: String) -> String {
        "•" + pan.suffix(4)
    }

    static func format(validThru: String?) -> String {
        validThru.map { $0.prefix(2) + "/" + $0.suffix(2) } ?? ""
    }
}
