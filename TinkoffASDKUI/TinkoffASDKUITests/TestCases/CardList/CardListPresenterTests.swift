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

    func test_viewNumberOfSections_for_showingCards_state() throws {
        // given
        let dependencies = buildDependecies()
        dependencies.sut.setScreenState(.showingCards)
        let expectedNumberOfSections = 2

        // when
        let numberOfSections = dependencies.sutAsProtocol.viewNumberOfSections()

        // then
        XCTAssertEqual(numberOfSections, expectedNumberOfSections)
    }

    func test_viewNumberOfSections_for_editingCards_state() throws {
        // given
        let dependencies = buildDependecies()
        dependencies.sut.setScreenState(.editingCards)
        let expectedNumberOfSections = 1

        // when
        let numberOfSections = dependencies.sutAsProtocol.viewNumberOfSections()

        // then
        XCTAssertEqual(numberOfSections, expectedNumberOfSections)
    }

    func test_viewCellModel_for_addCard_section() throws {
        // given
        let dependencies = buildDependecies()
        dependencies.sut.setScreenState(.showingCards)
        let expectedModelType = IconTitleView.Configuration.self

        // when
        let cellModel: IconTitleView.Configuration? = dependencies.sutAsProtocol.viewCellModel(section: .addCard, itemIndex: 0)

        // then
        switch cellModel {
        case .none:
            XCTFail("no value")
        case let .some(wrapped):
            XCTAssertTrue(type(of: wrapped) == expectedModelType)
        }
    }

    func test_viewCellModel_for_cards_section() throws {
        // given
        let dependencies = buildDependecies()
        let expectedModelType = CardList.Card.self
        let paymentCards = buildActiveCardsCache()

        dependencies.sut.setActiveCardsCache(paymentCards)

        // when
        let cellModel: CardList.Card? = dependencies.sutAsProtocol.viewCellModel(section: .cards, itemIndex: 0)

        // then
        switch cellModel {
        case .none:
            XCTFail("no value")
        case let .some(wrapped):
            XCTAssertTrue(type(of: wrapped) == expectedModelType)
        }
    }

    func test_viewNumberOfItems_for_cards_section() throws {
        // given
        let dependencies = buildDependecies()
        let expectedNumberOfItems = 1
        dependencies.sut.setActiveCardsCache(buildActiveCardsCache())

        // when
        let numberOfItems = dependencies.sutAsProtocol.viewNumberOfItems(forSection: .cards)

        // then
        XCTAssertEqual(numberOfItems, expectedNumberOfItems)
    }

    func test_viewNumberOfItems_for_addCard_section() throws {
        // given
        let dependencies = buildDependecies()
        let expectedNumberOfItems = 1

        // when
        let numberOfItems = dependencies.sutAsProtocol.viewNumberOfItems(forSection: .addCard)

        // then
        XCTAssertEqual(numberOfItems, expectedNumberOfItems)
    }

    func test_viewNativeAlertDidTapButton() throws {
        // given
        let dependencies = buildDependecies()

        // when
        dependencies.sutAsProtocol.viewNativeAlertDidTapButton()

        // then
        XCTAssertEqual(dependencies.mockView.dismissAlertCallCounter, 1)
    }

    func test_viewDidTapPrimaryButton() throws {
        // given
        let dependencies = buildDependecies()
        var didCallOnAddNewCard = false
        dependencies.sut.onAddNewCardTap = {
            didCallOnAddNewCard = true
        }

        // when
        dependencies.sutAsProtocol.viewDidTapPrimaryButton()

        // then
        XCTAssertEqual(true, didCallOnAddNewCard)
    }

    func test_viewDidTapEditButton_when_showingCards() throws {
        // given
        let dependencies = buildDependecies()
        dependencies.sut.setScreenState(.showingCards)
        let view = dependencies.mockView

        // when
        dependencies.sutAsProtocol.viewDidTapEditButton()

        // then
        XCTAssertEqual(view.hideStubCallCounter, 1)
        XCTAssertEqual(view.showDoneEditingButtonCallCounter, 1)
        XCTAssertEqual(view.reloadCallCounter, 1)
    }

    func test_viewDidTapEditButton_when_editingCards() throws {
        // given
        let dependencies = buildDependecies()
        dependencies.sut.setScreenState(.editingCards)
        let view = dependencies.mockView

        // when
        dependencies.sutAsProtocol.viewDidTapEditButton()

        // then
        XCTAssertEqual(view.hideStubCallCounter, 0)
        XCTAssertEqual(view.showDoneEditingButtonCallCounter, 0)
        XCTAssertEqual(view.reloadCallCounter, 0)
    }

    func test_viewDidTapDoneEditingButton() throws {
        // given
        let dependencies = buildDependecies()
        dependencies.sut.setScreenState(.editingCards)
        let view = dependencies.mockView

        // when
        dependencies.sutAsProtocol.viewDidTapDoneEditingButton()

        // then
        XCTAssertEqual(view.showEditButtonCallCounter, 1)
        XCTAssertEqual(view.hideStubCallCounter, 1)
        XCTAssertEqual(view.reloadCallCounter, 1)
    }

    func test_viewDidLoad() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView
        let expectation = expectation(description: #function)
        dependencies.mockPaymentCardsProvider.fetchActiveCardsStub = { [weak self] closure in
            guard let self = self else { return }
            closure(.success(self.buildActiveCardsCache()))
            expectation.fulfill()
        }

        // when
        dependencies.sutAsProtocol.viewDidLoad()
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(view.showShimmerCallCounter, 1)
        XCTAssertEqual(dependencies.mockPaymentCardsProvider.fetchActiveCardsCallCounter, 1)
        XCTAssertEqual(view.hideShimmerCallCounter, 1)
    }

    func test_viewDidHideLoadingSnackbar_deactivateCard_success() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView
        dependencies.sut.setDeactivateCardResult(.success(()))

        // when
        dependencies.sutAsProtocol.viewDidHideLoadingSnackbar()

        // then
        XCTAssertEqual(view.enableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(dependencies.mockPaymentCardsProvider.fetchActiveCardsCallCounter, 1)
    }

    func test_viewDidHideLoadingSnackbar_deactivateCard_failure() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView
        dependencies.sut.setActiveCardsCache(buildActiveCardsCache())
        dependencies.sut.setDeactivateCardResult(.failure(TestsError.basic))

        // when
        dependencies.sutAsProtocol.viewDidHideLoadingSnackbar()

        // then
        XCTAssertEqual(view.enableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(view.showNativeAlertCallCounter, 1)
    }

    func test_view_didTapDeleteOn_success() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView
        let cardListCard = buildCardList()
        let expectation = expectation(description: #function)

        dependencies.mockPaymentCardsProvider.deactivateCardStub = { cardId, closure in
            closure(.success(()))
            expectation.fulfill()
        }

        // when
        dependencies.sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(view.disableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(view.showLoadingSnackbarCallCounter, 1)
        XCTAssertEqual(dependencies.mockPaymentCardsProvider.deactivateCardCallCounter, 1)
        XCTAssertEqual(view.hideLoadingSnackbarCallCounter, 1)
    }

    func test_view_didTapDeleteOn_failure() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView
        let cardListCard = buildCardList()
        let expectation = expectation(description: #function)

        dependencies.sut.setActiveCardsCache(buildActiveCardsCache())
        dependencies.mockPaymentCardsProvider.deactivateCardStub = { cardId, closure in
            closure(.failure(TestsError.basic))
            expectation.fulfill()
        }

        // when
        dependencies.sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(view.disableViewUserInteractionCallCounter, 1)
        XCTAssertEqual(view.showLoadingSnackbarCallCounter, 1)
        XCTAssertEqual(dependencies.mockPaymentCardsProvider.deactivateCardCallCounter, 1)
        XCTAssertEqual(view.hideLoadingSnackbarCallCounter, 1)
    }

    func test_viewDidHideShimmer_success() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView

        dependencies.sut.setFetchedActiveCardsResult(.success(buildActiveCardsCache()))

        // when
        dependencies.sutAsProtocol.viewDidHideShimmer()

        // then
        XCTAssertEqual(view.hideStubCallCounter, 1)
        XCTAssertEqual(view.reloadCallCounter, 1)
    }

    func test_viewDidHideShimmer_success_emptyCards() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView
        let expectation = expectation(description: #function)

        dependencies.sut.setFetchedActiveCardsResult(.success([]))

        var isNoCardsMode = false
        view.showStubStub = { mode in
            if case .noCards = mode {
                isNoCardsMode = true
                expectation.fulfill()
            }
        }

        // when
        dependencies.sutAsProtocol.viewDidHideShimmer()
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(view.reloadCallCounter, 2)
        XCTAssertEqual(view.hideStubCallCounter, 3)
        XCTAssertEqual(view.showStubCallCounter, 1)
        XCTAssertTrue(isNoCardsMode)
    }

    func test_viewDidHideShimmer_failure() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView

        dependencies.sut.setFetchedActiveCardsResult(.failure(TestsError.basic))

        // when
        dependencies.sutAsProtocol.viewDidHideShimmer()

        // then
        XCTAssertEqual(view.hideStubCallCounter, 1)
        XCTAssertEqual(view.showStubCallCounter, 1)
    }

    func test_viewDidTapCard_cardIndex() throws {
        // given
        let dependencies = buildDependecies()
        var onSelectCardCalled = false
        let expectation = expectation(description: #function)
        dependencies.sut.setActiveCardsCache(buildActiveCardsCache())
        dependencies.sut.onSelectCard = { card in
            onSelectCardCalled = true
            expectation.fulfill()
        }

        // when
        dependencies.sutAsProtocol.viewDidTapCard(cardIndex: 0)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(onSelectCardCalled, true)
    }

    func test_viewDidTapCard_viewDidTapAddCardCell() throws {
        // given
        let dependencies = buildDependecies()
        var onAddNewCardTapCalled = false
        let expectation = expectation(description: #function)
        dependencies.sut.setActiveCardsCache(buildActiveCardsCache())
        dependencies.sut.onAddNewCardTap = {
            onAddNewCardTapCalled = true
            expectation.fulfill()
        }

        // when
        dependencies.sutAsProtocol.viewDidTapAddCardCell()
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(onAddNewCardTapCalled, true)
    }
}

// MARK: - Helpers

extension CardListPresenterTests {

    struct Dependencies {
        let sut: CardListPresenter
        let sutAsProtocol: ICardListViewOutput

        let mockPaymentSystemImageResolver: MockPaymentSystemImageResolver
        let mockPaymentCardsProvider: MockPaymentCardsProvider
        let mockBankResolver: MockBankResolver
        let mockPaymentSystemResolver: MockPaymentSystemResolver
        let mockView: MockCardListViewInput
    }

    func buildDependecies() -> Dependencies {
        let mockPaymentSystemImageResolver = MockPaymentSystemImageResolver()
        let mockPaymentCardsProvider = MockPaymentCardsProvider()
        let mockBankResolver = MockBankResolver()
        let mockPaymentSystemResolver = MockPaymentSystemResolver()
        let mockView = MockCardListViewInput()

        let sut = CardListPresenter(
            imageResolver: mockPaymentSystemImageResolver,
            provider: mockPaymentCardsProvider,
            bankResolver: mockBankResolver,
            paymentSystemResolver: mockPaymentSystemResolver
        )

        sut.view = mockView

        return Dependencies(
            sut: sut,
            sutAsProtocol: sut,
            mockPaymentSystemImageResolver: mockPaymentSystemImageResolver,
            mockPaymentCardsProvider: mockPaymentCardsProvider,
            mockBankResolver: mockBankResolver,
            mockPaymentSystemResolver: mockPaymentSystemResolver,
            mockView: mockView
        )
    }

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
            assembledText: "",
            isInEditingMode: true
        )
    }
}
