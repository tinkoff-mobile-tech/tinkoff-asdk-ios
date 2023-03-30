//
//  CardListPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 19.12.2022.
//

import Foundation

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation
import XCTest

final class CardListPresenterTests: BaseTestCase {

    // Dependencies
    var sutAsProtocol: ICardListViewOutput! { sut }

    var sut: CardListPresenter!
    var mockPaymentSystemImageResolver: MockPaymentSystemImageResolver!
    var mockBankResolver: MockBankResolver!
    var mockPaymentSystemResolver: MockPaymentSystemResolver!
    var mockView: MockCardListViewInput!
    var cardsControllerMock: CardsControllerMock!
    var router: CardListRouterMock!
    var output: CardListPresenterOutputMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockPaymentSystemImageResolver = MockPaymentSystemImageResolver()
        mockBankResolver = MockBankResolver()
        mockPaymentSystemResolver = MockPaymentSystemResolver()
        mockView = MockCardListViewInput()
        cardsControllerMock = CardsControllerMock()
        router = CardListRouterMock()
        output = CardListPresenterOutputMock()

        sut = CardListPresenter(
            screenConfiguration: buildScreenConfiguration(),
            cardsController: cardsControllerMock,
            router: router,
            imageResolver: mockPaymentSystemImageResolver,
            bankResolver: mockBankResolver,
            paymentSystemResolver: mockPaymentSystemResolver,
            output: output
        )

        sut.view = mockView
    }

    override func tearDown() {
        sut = nil
        mockPaymentSystemImageResolver = nil
        mockBankResolver = nil
        mockPaymentSystemResolver = nil
        mockView = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad() throws {
        // given
        let expectation = expectation(description: #function)
        cardsControllerMock.getActiveCardsStub = { [weak self] completion in
            guard let self = self else { return }
            completion(.success(self.buildActiveCardsCache()))
            expectation.fulfill()
        }

        // when
        sutAsProtocol.viewDidLoad()
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(mockView.showShimmerCallCounter, 1)
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 1)
        XCTAssertEqual(mockView.hideShimmerCallCounter, 1)
    }

    func test_viewDidTapEditButton_when_showingCards() throws {
        // given
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(buildActiveCardsCache()))

        // when
        sutAsProtocol.viewDidTapEditButton()

        // then
        XCTAssertEqual(mockView.hideStubCallCounter, 2)
        XCTAssertEqual(mockView.showDoneEditingButtonCallCounter, 2)
        XCTAssertEqual(mockView.reloadCallCounter, 2)
    }

    func test_viewDidTapEditButton_when_editingCards() throws {
        // when
        sutAsProtocol.viewDidTapEditButton()

        // then
        XCTAssertEqual(mockView.hideStubCallCounter, 0)
        XCTAssertEqual(mockView.showDoneEditingButtonCallCounter, 0)
        XCTAssertEqual(mockView.reloadCallCounter, 0)
    }

    func test_viewDidTapDoneEditingButton() throws {
        // when
        sutAsProtocol.viewDidTapDoneEditingButton()

        // then
        XCTAssertEqual(mockView.showEditButtonCallCounter, 2)
        XCTAssertEqual(mockView.hideStubCallCounter, 1)
        XCTAssertEqual(mockView.reloadCallCounter, 1)
    }

    func test_viewDidHideLoadingSnackbar_deactivateCard_success() throws {
        // given
        sutAsProtocol.view(didTapDeleteOn: buildCardListCard())

        // when
        sutAsProtocol.viewDidHideRemovingCardSnackBar()

        // then
        XCTAssertEqual(mockView.enableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 0)
    }

    func test_viewDidHideLoadingSnackbar_deactivateCard_failure() throws {
        allureId(2397534, "Инициализируем событие алерта при ошибке удаление")
        // given
        let cards = buildActiveCardsCache()
        cardsControllerMock.removeCardStub = { _, completion in
            completion(.failure(TestsError.basic))
        }
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(cards))
        sutAsProtocol.view(didTapDeleteOn: buildCardListCard())
        mockView.reloadCallCounter = .zero

        // when
        sutAsProtocol.viewDidHideRemovingCardSnackBar()

        // then
        XCTAssertEqual(mockView.enableViewUserInteractionCallCounter, 2)
        XCTAssertEqual(mockView.showNativeAlertCallCounter, 1)
        XCTAssertEqual(mockView.reloadCallCounter, .zero)
    }

    func test_view_didTapDeleteOn_success() throws {
        // given
        let cardListCard = buildCardListCard()
        let expectation = expectation(description: #function)

        cardsControllerMock.removeCardStub = { _, completion in
            completion(.success(RemoveCardPayload(cardId: "2", cardStatus: .deleted)))
            expectation.fulfill()
        }

        // when
        sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(mockView.disableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(mockView.showRemovingCardSnackBarCallCounter, 1)
        XCTAssertEqual(cardsControllerMock.removeCardCallsCount, 1)
        XCTAssertEqual(mockView.hideLoadingSnackbarCallCounter, 1)
    }

    func test_view_didTapDeleteOn_failure() throws {
        // given
        let cardListCard = buildCardListCard()
        let expectation = expectation(description: #function)

        cardsControllerMock.removeCardStub = { _, completion in
            completion(.failure(TestsError.basic))
            expectation.fulfill()
        }

        // when
        sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(mockView.disableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(mockView.showRemovingCardSnackBarCallCounter, 1)
        XCTAssertEqual(cardsControllerMock.removeCardCallsCount, 1)
        XCTAssertEqual(mockView.hideLoadingSnackbarCallCounter, 1)
    }

    func test_viewDidHideShimmer_success_emptyCards_shouldShowNoCardsStub() throws {
        // given
        let fetchCardsResult: Result<[PaymentCard], Error> = .success([])
        var isNoCardsMode = false

        mockView.showStubStub = { mode in
            if case StubMode.noCardsInCardList = mode {
                isNoCardsMode = true
            }
        }

        // when
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: fetchCardsResult)

        // then
        XCTAssertEqual(mockView.reloadCallCounter, 2)
        XCTAssertEqual(mockView.hideStubCallCounter, 2)
        XCTAssertEqual(mockView.showStubCallCounter, 1)
        XCTAssertTrue(isNoCardsMode, "should show no cards stub")
    }

    func test_viewDidHideShimmer_success_emptyCards_shouldShowCards() throws {
        // given
        let fetchCardsResult: Result<[PaymentCard], Error> = .success(buildActiveCardsCache())

        // when
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: fetchCardsResult)

        // then
        XCTAssertEqual(mockView.reloadCallCounter, 1)
        XCTAssertEqual(mockView.hideStubCallCounter, 1)
    }

    func test_viewDidTapCard_withCardListUseCase_shouldDoNothing() throws {
        // given
        let cards = buildActiveCardsCache()
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(cards))

        // when
        sutAsProtocol.viewDidTapCard(cardIndex: 0)

        // then
        XCTAssertEqual(output.cardListWillCloseAfterSelectingCalls.count, 0)
        XCTAssertEqual(mockView.dismissCallCounter, 0)
    }

    func test_viewDidTapAddCardCell_shouldOpenAddNewCard() throws {
        // when
        sutAsProtocol.viewDidTapAddCardCell()

        // then
        XCTAssertEqual(router.openAddNewCardsCallsCount, 1)
    }

    func test_viewDidTapDelete() throws {
        allureId(2397531, "Отправляем запрос удаления карты при тапе на кнопку")
        allureId(2397536, "Уменьшение списка карт при успешном удаление карты")
        allureId(2397533, "Инициализируем заглушку в случае удаления последней карты")
        // given
        let cards = buildActiveCardsCache()
        let card = try XCTUnwrap(cards.first)
        let cardListCardToDelete = CardList.Card(from: card)
        var passedCardId = ""
        var didDeleteCardFromView = false
        var didShowNoCardsStub = false

        mockView.reloadStub = { sections in
            let cardList = sections.getCardListFromCardsSection()
            didDeleteCardFromView = cardList.count == (cards.count - 1) &&
                !cardList.contains { $0.id == card.cardId }
        }

        mockView.showStubStub = {
            if case StubMode.noCardsInCardList = $0 {
                didShowNoCardsStub = true
            }
        }

        cardsControllerMock.removeCardStub = { cardId, completion in
            passedCardId = cardId
            completion(.success(RemoveCardPayload(cardId: cardId, cardStatus: .deleted)))
        }

        sut.viewDidHideShimmer(fetchCardsResult: .success(cards))
        sut.viewDidTapEditButton()

        // when
        sut.view(didTapDeleteOn: cardListCardToDelete)
        sut.viewDidHideRemovingCardSnackBar()

        // then
        XCTAssertEqual(mockView.showRemovingCardSnackBarCallCounter, 1)
        XCTAssertEqual(mockView.disableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(cardsControllerMock.removeCardCallsCount, 1)
        XCTAssertEqual(passedCardId, card.cardId)
        XCTAssertEqual(mockView.hideLoadingSnackbarCallCounter, 1)
        XCTAssertTrue(didDeleteCardFromView)
        XCTAssertTrue(didShowNoCardsStub)
        XCTAssertEqual(mockView.hideRightBarButtonCalCounter, 1)
    }

    func test_addNewCardDidReceive() {
        allureId(2397518, "Отображение нового списка карт в случае успешного добавления без прохождения 3ds")
        allureId(2397502)
        // given
        let cards = buildActiveCardsCache()
        let paymentCard = PaymentCard.fake()
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(cards))

        // when
        sut.addNewCardDidReceive(result: .succeded(paymentCard))

        // then
        XCTAssertEqual(mockView.showAddedCardSnackbarCallCounter, 1)
    }

    func test_viewDidShowAddedCardSnackbar() {
        allureId(2397518, "Отображение нового списка карт в случае успешного добавления без прохождения 3ds")
        allureId(2397502)
        // when
        sut.viewDidShowAddedCardSnackbar()

        // then
        let counter = mockView.showDoneEditingButtonCallCounter + mockView.showEditButtonCallCounter
        XCTAssertTrue(counter > 0)
        XCTAssertEqual(mockView.hideStubCallCounter, 1)
        XCTAssertEqual(mockView.reloadCallCounter, 1)
    }
}

// MARK: - Helpers

extension CardListPresenterTests {

    func buildActiveCardsCache() -> [PaymentCard] {
        [
            PaymentCard(
                pan: "220138******0104",
                cardId: "458542919",
                status: .active,
                parentPaymentId: nil,
                expDate: "1129"
            ),
        ]
    }

    func buildCardListCard() -> CardList.Card {
        CardList.Card(
            id: "",
            pan: "",
            cardModel: DynamicIconCardView.Model(data: DynamicIconCardView.Data()),
            bankNameText: "",
            cardNumberText: "",
            isInEditingMode: true,
            hasCheckmarkInNormalMode: false
        )
    }

    func buildScreenConfiguration(useCase: CardListScreenConfiguration.UseCase = .cardList) -> CardListScreenConfiguration {
        CardListScreenConfiguration(
            useCase: useCase,
            selectedCardId: nil
        )
    }
}

extension Array where Element == CardListSection {

    func getCardListFromCardsSection() -> [CardList.Card] {
        for section in self {
            if case let .cards(cardList) = section {
                return cardList
            }
        }

        return []
    }
}
