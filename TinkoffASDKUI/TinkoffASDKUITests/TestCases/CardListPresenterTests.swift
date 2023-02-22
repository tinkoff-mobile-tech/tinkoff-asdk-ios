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
    var mockPaymentCardsProvider: MockPaymentCardsProvider!
    var mockBankResolver: MockBankResolver!
    var mockPaymentSystemResolver: MockPaymentSystemResolver!
    var mockView: MockCardListViewInput!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        let mockPaymentSystemImageResolver = MockPaymentSystemImageResolver()
        let mockPaymentCardsProvider = MockPaymentCardsProvider()
        let mockBankResolver = MockBankResolver()
        let mockPaymentSystemResolver = MockPaymentSystemResolver()
        let mockView = MockCardListViewInput()
        let screenConfiguration = buildScreenConfiguration()

        let sut = CardListPresenter(
            screenConfiguration: screenConfiguration,
            imageResolver: mockPaymentSystemImageResolver,
            provider: mockPaymentCardsProvider,
            bankResolver: mockBankResolver,
            paymentSystemResolver: mockPaymentSystemResolver
        )

        sut.view = mockView

        self.sut = sut
        self.mockPaymentSystemImageResolver = mockPaymentSystemImageResolver
        self.mockPaymentCardsProvider = mockPaymentCardsProvider
        self.mockBankResolver = mockBankResolver
        self.mockPaymentSystemResolver = mockPaymentSystemResolver
        self.mockView = mockView
    }

    override func tearDown() {
        sut = nil
        mockPaymentSystemImageResolver = nil
        mockPaymentCardsProvider = nil
        mockBankResolver = nil
        mockPaymentSystemResolver = nil
        mockView = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad() throws {
        // given
        let expectation = expectation(description: #function)
        mockPaymentCardsProvider.fetchActiveCardsStub = { [weak self] closure in
            guard let self = self else { return }
            closure(.success(self.buildActiveCardsCache()))
            expectation.fulfill()
        }

        // when
        sutAsProtocol.viewDidLoad()
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(mockView.showShimmerCallCounter, 1)
        XCTAssertEqual(mockPaymentCardsProvider.fetchActiveCardsCallCounter, 1)
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
        mockPaymentCardsProvider.deactivateCardStub = { id, completion in
            completion(.success(()))
        }

        sutAsProtocol.view(didTapDeleteOn: buildCardList())

        // when
        sutAsProtocol.viewDidHideRemovingCardSnackBar()

        // then
        XCTAssertEqual(mockView.enableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(mockPaymentCardsProvider.fetchActiveCardsCallCounter, 1)
    }

    func test_viewDidHideLoadingSnackbar_deactivateCard_failure() throws {
        // given
        mockPaymentCardsProvider.deactivateCardStub = { id, completion in
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

        mockPaymentCardsProvider.deactivateCardStub = { cardId, closure in
            closure(.success(()))
            expectation.fulfill()
        }

        // when
        sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(mockView.disableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(mockView.showLoadingSnackbarCallCounter, 1)
        XCTAssertEqual(mockPaymentCardsProvider.deactivateCardCallCounter, 1)
        XCTAssertEqual(mockView.hideLoadingSnackbarCallCounter, 1)
    }

    func test_view_didTapDeleteOn_failure() throws {
        // given
        let cardListCard = buildCardList()
        let expectation = expectation(description: #function)

        mockPaymentCardsProvider.deactivateCardStub = { cardId, closure in
            closure(.failure(TestsError.basic))
            expectation.fulfill()
        }

        // when
        sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(mockView.disableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(mockView.showLoadingSnackbarCallCounter, 1)
        XCTAssertEqual(mockPaymentCardsProvider.deactivateCardCallCounter, 1)
        XCTAssertEqual(mockView.hideLoadingSnackbarCallCounter, 1)
    }

    func test_viewDidHideShimmer_success_emptyCards_shouldShowNoCardsStub() throws {
        // given
        let fetchCardsResult: Result<[PaymentCard], Error> = .success([])
        var isNoCardsMode = false

        mockView.showStubStub = { mode in
            if case StubMode.noCards = mode {
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

    func test_viewDidTapCard_cardIndex() throws {
        // given
        var onSelectCardCalled = false
        let expectation = expectation(description: #function)
        sut.onSelectCard = { card in
            onSelectCardCalled = true
            expectation.fulfill()
        }

        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(buildActiveCardsCache()))

        // when
        sutAsProtocol.viewDidTapCard(cardIndex: 0)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(onSelectCardCalled, true)
    }

    func test_viewDidTapCard_viewDidTapAddCardCell() throws {
        // given
        var onAddNewCardTapCalled = false
        let expectation = expectation(description: #function)
        sut.onAddNewCardTap = {
            onAddNewCardTapCalled = true
            expectation.fulfill()
        }

        // when
        sutAsProtocol.viewDidTapAddCardCell()
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(onAddNewCardTapCalled, true)
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

    func buildScreenConfiguration() -> CardListScreenConfiguration {
        CardListScreenConfiguration(
            listItemsAreSelectable: true,
            navigationTitle: "",
            addNewCardCellTitle: "",
            selectedCardId: nil
        )
    }
}
