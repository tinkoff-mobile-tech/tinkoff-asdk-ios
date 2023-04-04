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

final class CardListPresenterTests: XCTestCase {

    // Dependencies
    var sutAsProtocol: ICardListViewOutput! { sut }

    var sut: CardListPresenter!
    var mockPaymentSystemImageResolver: MockPaymentSystemImageResolver!
    var mockBankResolver: MockBankResolver!
    var mockPaymentSystemResolver: MockPaymentSystemResolver!
    var mockView: MockCardListViewInput!
    var cardsController: CardsControllerMock!
    var router: CardListRouterMock!
    var output: CardListPresenterOutputMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockPaymentSystemImageResolver = MockPaymentSystemImageResolver()
        mockBankResolver = MockBankResolver()
        mockPaymentSystemResolver = MockPaymentSystemResolver()
        mockView = MockCardListViewInput()
        cardsController = CardsControllerMock()
        router = CardListRouterMock()
        output = CardListPresenterOutputMock()

        sut = CardListPresenter(
            screenConfiguration: buildScreenConfiguration(),
            cardsController: cardsController,
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
        cardsController.getActiveCardsStub = { [weak self] completion in
            guard let self = self else { return }
            completion(.success(self.buildActiveCardsCache()))
            expectation.fulfill()
        }

        // when
        sutAsProtocol.viewDidLoad()
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(mockView.showShimmerCallCounter, 1)
        XCTAssertEqual(cardsController.getActiveCardsCallsCount, 1)
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
        sutAsProtocol.view(didTapDeleteOn: buildCardList())

        // when
        sutAsProtocol.viewDidHideRemovingCardSnackBar()

        // then
        XCTAssertEqual(mockView.enableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(cardsController.getActiveCardsCallsCount, 0)
    }

    func test_viewDidHideLoadingSnackbar_deactivateCard_failure() throws {
        // given
        cardsController.removeCardStub = { _, completion in
            completion(.failure(TestsError.basic))
        }

        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(buildActiveCardsCache()))
        sutAsProtocol.view(didTapDeleteOn: buildCardList())

        // when
        sutAsProtocol.viewDidHideRemovingCardSnackBar()

        // then
        XCTAssertEqual(mockView.enableViewUserInteractionCallCounter, 2)
        XCTAssertEqual(mockView.showNativeAlertCallCounter, 1)
    }

    func test_view_didTapDeleteOn_success() throws {
        // given
        let cardListCard = buildCardList()
        let expectation = expectation(description: #function)

        cardsController.removeCardStub = { _, completion in
            completion(.success(RemoveCardPayload(cardId: "2", cardStatus: .deleted)))
            expectation.fulfill()
        }

        // when
        sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(mockView.disableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(mockView.showLoadingSnackbarCallCounter, 1)
        XCTAssertEqual(cardsController.removeCardCallsCount, 1)
        XCTAssertEqual(mockView.hideLoadingSnackbarCallCounter, 1)
    }

    func test_view_didTapDeleteOn_failure() throws {
        // given
        let cardListCard = buildCardList()
        let expectation = expectation(description: #function)

        cardsController.removeCardStub = { _, completion in
            completion(.failure(TestsError.basic))
            expectation.fulfill()
        }

        // when
        sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(mockView.disableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(mockView.showLoadingSnackbarCallCounter, 1)
        XCTAssertEqual(cardsController.removeCardCallsCount, 1)
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
        XCTAssertEqual(mockView.hideStubCallCounter, 3)
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

    func test_getCardList_unknownCustomer_error() {
        // given
        let noSuchCustomerErrorCode = 7
        var didShowNoCardsStub = false
        mockView.showStubStub = { stubMode in
            if case StubMode.noCardsInCardList = stubMode {
                didShowNoCardsStub = true
            }
        }

        // when
        sutAsProtocol.viewDidHideShimmer(
            fetchCardsResult: .failure(APIFailureError(errorCode: noSuchCustomerErrorCode))
        )

        // then
        XCTAssertEqual(mockView.showStubCallCounter, 1)
        XCTAssertTrue(didShowNoCardsStub)
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

    func buildCardList() -> CardList.Card {
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
