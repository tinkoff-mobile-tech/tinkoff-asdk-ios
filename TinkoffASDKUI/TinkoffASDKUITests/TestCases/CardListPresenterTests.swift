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

    func test_viewDidTapNoCardsStubButton() throws {
        // given
        let dependencies = buildDependecies()

        var onAddNewCardTapCalled = false
        let expectation = expectation(description: #function)
        dependencies.sut.onAddNewCardTap = {
            onAddNewCardTapCalled = true
            expectation.fulfill()
        }
        // when

        dependencies.sutAsProtocol.viewDidTapNoCardsStubButton()
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(onAddNewCardTapCalled, true)
    }

    func test_viewDidTapNoNetworkStubButton() throws {
        // given
        let dependencies = buildDependecies()

        // when

        dependencies.sutAsProtocol.viewDidTapNoNetworkStubButton()

        // then
        XCTAssertEqual(dependencies.mockView.showShimmerCallCounter, 1)
    }

    func test_viewDidTapServerErrorStubButton() throws {
        // given
        let dependencies = buildDependecies()

        // when

        dependencies.sutAsProtocol.viewDidTapServerErrorStubButton()

        // then
        XCTAssertEqual(dependencies.mockView.dismissCallCounter, 1)
    }

    func test_viewDidTapEditButton_when_showingCards() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView

        dependencies.sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(buildActiveCardsCache()))

        // when
        dependencies.sutAsProtocol.viewDidTapEditButton()

        // then
        XCTAssertEqual(view.hideStubCallCounter, 2)
        XCTAssertEqual(view.showDoneEditingButtonCallCounter, 2)
        XCTAssertEqual(view.reloadCallCounter, 2)
    }

    func test_viewDidTapEditButton_when_editingCards() throws {
        // given
        let dependencies = buildDependecies()
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
        let view = dependencies.mockView

        // when
        dependencies.sutAsProtocol.viewDidTapDoneEditingButton()

        // then
        XCTAssertEqual(view.showEditButtonCallCounter, 2)
        XCTAssertEqual(view.hideStubCallCounter, 1)
        XCTAssertEqual(view.reloadCallCounter, 1)
    }

    func test_viewDidHideLoadingSnackbar_deactivateCard_success() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView

        dependencies.mockPaymentCardsProvider.deactivateCardStub = { id, completion in
            completion(.success(()))
        }

        dependencies.sutAsProtocol.view(didTapDeleteOn: buildCardList())

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

        dependencies.mockPaymentCardsProvider.deactivateCardStub = { id, completion in
            completion(.failure(TestsError.basic))
        }

        dependencies.sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(buildActiveCardsCache()))
        dependencies.sutAsProtocol.view(didTapDeleteOn: buildCardList())

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

    func test_viewDidHideShimmer_success_emptyCards_shouldShowNoCardsStub() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView
        let fetchCardsResult: Result<[PaymentCard], Error> = .success([])

        // when
        dependencies.sutAsProtocol.viewDidHideShimmer(fetchCardsResult: fetchCardsResult)

        // then
        XCTAssertEqual(view.reloadCallCounter, 2)
        XCTAssertEqual(view.hideStubCallCounter, 4)
        XCTAssertEqual(view.showNoCardsStubCallCounter, 1)
    }

    func test_viewDidHideShimmer_success_emptyCards_shouldShowCards() throws {
        // given
        let dependencies = buildDependecies()
        let view = dependencies.mockView
        let fetchCardsResult: Result<[PaymentCard], Error> = .success(buildActiveCardsCache())

        // when
        dependencies.sutAsProtocol.viewDidHideShimmer(fetchCardsResult: fetchCardsResult)

        // then
        XCTAssertEqual(view.reloadCallCounter, 1)
        XCTAssertEqual(view.hideStubCallCounter, 1)
    }

    func test_viewDidTapCard_cardIndex() throws {
        // given
        let dependencies = buildDependecies()
        var onSelectCardCalled = false
        let expectation = expectation(description: #function)
        dependencies.sut.onSelectCard = { card in
            onSelectCardCalled = true
            expectation.fulfill()
        }

        dependencies.sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(buildActiveCardsCache()))

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
