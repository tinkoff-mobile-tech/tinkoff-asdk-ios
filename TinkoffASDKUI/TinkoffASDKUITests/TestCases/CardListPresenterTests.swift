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
    var paymentSystemImageResolverMock: PaymentSystemImageResolverMock!
    var bankResolverMock: BankResolverMock!
    var paymentSystemResolverMock: PaymentSystemResolverMock!
    var viewMock: CardListViewInputMock!
    var cardsControllerMock: CardsControllerMock!
    var router: CardListRouterMock!
    var output: CardListPresenterOutputMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        paymentSystemImageResolverMock = PaymentSystemImageResolverMock()
        bankResolverMock = BankResolverMock()
        paymentSystemResolverMock = PaymentSystemResolverMock()
        viewMock = CardListViewInputMock()
        cardsControllerMock = CardsControllerMock()
        router = CardListRouterMock()
        output = CardListPresenterOutputMock()
    }

    override func tearDown() {
        sut = nil
        paymentSystemImageResolverMock = nil
        bankResolverMock = nil
        paymentSystemResolverMock = nil
        viewMock = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad() throws {
        allureId(2401647, "Инициализируем шиммер при инициализации экрана Списка Карт")
        allureId(2397505, "Отправляем запрос получения списка при инициализации SDK")

        // given
        prepareSut()

        let card = PaymentCard(pan: "", cardId: "", status: .active, parentPaymentId: nil, expDate: "")
        cardsControllerMock.getActiveCardsCompletionClosureInput = .success([card])

        // when
        sutAsProtocol.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.showShimmerCallsCount, 1)
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 1)
        XCTAssertEqual(viewMock.hideShimmerCallsCount, 1)
    }

    func test_viewDidTapEditButton_when_showingCards() throws {
        allureId(2397530, "Переход в состояние редактирования списка карт")

        // given
        prepareSut()
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(buildActiveCardsCache()))

        // when
        sutAsProtocol.viewDidTapEditButton()

        // then
        let addCardSection = viewMock.reloadReceivedArguments?.first(where: {
            if case CardListSection.addCard = $0 { return true }
            return false
        })

        XCTAssertEqual(viewMock.hideStubCallsCount, 2)
        XCTAssertEqual(viewMock.showDoneEditingButtonCallsCount, 2)
        XCTAssertEqual(viewMock.reloadCallsCount, 2)
        XCTAssertNil(addCardSection)
    }

    func test_viewDidTapEditButton_when_editingCards() throws {
        // given
        prepareSut()

        // when
        sutAsProtocol.viewDidTapEditButton()

        // then
        XCTAssertEqual(viewMock.hideStubCallsCount, 0)
        XCTAssertEqual(viewMock.showDoneEditingButtonCallsCount, 0)
        XCTAssertEqual(viewMock.reloadCallsCount, 0)
    }

    func test_viewDidTapDoneEditingButton() throws {
        // given
        prepareSut()

        // when
        sutAsProtocol.viewDidTapDoneEditingButton()

        // then
        XCTAssertEqual(viewMock.showEditButtonCallsCount, 2)
        XCTAssertEqual(viewMock.hideStubCallsCount, 1)
        XCTAssertEqual(viewMock.reloadCallsCount, 1)
    }

    func test_viewDidHideLoadingSnackbar_deactivateCard_success() throws {
        // given
        let payload = RemoveCardPayload(cardId: "123", cardStatus: .active)
        cardsControllerMock.removeCardCompletionClosureInput = .success(payload)
        prepareSut()
        sutAsProtocol.view(didTapDeleteOn: buildCardListCard())

        // when
        sutAsProtocol.viewDidHideRemovingCardSnackBar()

        // then
        XCTAssertEqual(viewMock.enableViewUserInteractionCallsCount, 1)
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 0)
    }

    func test_viewUpdatesSelectedCard() throws {
        // given
        prepareSut()
        let fakeCard = PaymentCard.fake()
        let cardList = buildCardListCard()
        cardsControllerMock.removeCardCompletionClosureInput = .success(.init(cardId: cardList.id, cardStatus: .active))

        sutAsProtocol.view(didTapDeleteOn: cardList)
        sut.addNewCardDidReceive(result: .succeded(fakeCard))

        // when
        sutAsProtocol.viewDidHideRemovingCardSnackBar()

        // then
        let arg = try XCTUnwrap(viewMock.reloadReceivedArguments?.first)
        if case let .cards(data) = arg {
            XCTAssertEqual(data.first?.id, fakeCard.cardId)
        } else {
            XCTFail()
        }
    }

    func test_viewDidHideLoadingSnackbar_deactivateCard_failure() throws {
        allureId(2397534, "Инициализируем событие алерта при ошибке удаление")
        // given
        prepareSut()
        let cards = buildActiveCardsCache()
        cardsControllerMock.removeCardCompletionClosureInput = .failure(TestsError.basic)
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(cards))
        sutAsProtocol.view(didTapDeleteOn: buildCardListCard())
        viewMock.reloadCallsCount = .zero

        // when
        sutAsProtocol.viewDidHideRemovingCardSnackBar()

        // then
        XCTAssertEqual(viewMock.enableViewUserInteractionCallsCount, 2)
        XCTAssertEqual(viewMock.showNativeAlertCallsCount, 1)
        XCTAssertEqual(viewMock.reloadCallsCount, .zero)
    }

    func test_view_didTapDeleteOn_success() throws {
        // given
        prepareSut()
        let cardListCard = buildCardListCard()
        let expectation = expectation(description: #function)

        cardsControllerMock.removeCardCompletionClosure = { expectation.fulfill() }
        cardsControllerMock.removeCardCompletionClosureInput = .success(RemoveCardPayload(cardId: "2", cardStatus: .deleted))

        // when
        sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(viewMock.disableViewUserInteractionCallsCount, 1)
        XCTAssertEqual(viewMock.showRemovingCardSnackBarCallsCount, 1)
        XCTAssertEqual(cardsControllerMock.removeCardCallsCount, 1)
        XCTAssertEqual(viewMock.hideLoadingSnackbarCallsCount, 1)
    }

    func test_view_didTapDeleteOn_failure() throws {
        // given
        prepareSut()
        let cardListCard = buildCardListCard()
        let expectation = expectation(description: #function)

        cardsControllerMock.removeCardCompletionClosure = { expectation.fulfill() }
        cardsControllerMock.removeCardCompletionClosureInput = .failure(TestsError.basic)

        // when
        sutAsProtocol.view(didTapDeleteOn: cardListCard)
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(viewMock.disableViewUserInteractionCallsCount, 1)
        XCTAssertEqual(viewMock.showRemovingCardSnackBarCallsCount, 1)
        XCTAssertEqual(cardsControllerMock.removeCardCallsCount, 1)
        XCTAssertEqual(viewMock.hideLoadingSnackbarCallsCount, 1)
    }

    func test_viewDidHideShimmer_failure_shouldShow_serverErrorStub() throws {
        allureId(2397506, "Инициализируем заглушку в случае ошибки получения списка карт")

        // given
        prepareSut()

        // when
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .failure(TestsError.basic))

        // then
        XCTAssertEqual(viewMock.showStubCallsCount, 1)
        XCTAssertEqual(viewMock.hideRightBarButtonCallsCount, 1)
        XCTAssertEqual(viewMock.showStubReceivedArguments, .serverError())
    }

    func test_viewDidHideShimmer_failure_shouldCloseScreen() {
        // given
        prepareSut()

        // when
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .failure(TestsError.basic))
        if case let .serverError(action) = viewMock.showStubReceivedArguments {
            action()
        }

        // then
        XCTAssertEqual(viewMock.closeScreenCallsCount, 1)
    }

    func test_viewDidHideShimmer_network_failure_shouldHideShimmer() {
        // given
        prepareSut()

        let card = PaymentCard(pan: "", cardId: "", status: .active, parentPaymentId: nil, expDate: "")
        cardsControllerMock.getActiveCardsCompletionClosureInput = .success([card])

        // when
        sutAsProtocol.viewDidHideShimmer(
            fetchCardsResult: .failure(NSError(domain: "", code: NSURLErrorNotConnectedToInternet))
        )
        if case let .noNetwork(action) = viewMock.showStubReceivedArguments {
            action()
        }

        // then
        XCTAssertEqual(viewMock.hideShimmerCallsCount, 1)
    }

    func test_viewDidHideShimmer_network_failure_shouldShow_noNetworkStub() throws {
        allureId(2397506, "Инициализируем заглушку в случае ошибки получения списка карт")

        // given
        prepareSut()

        // when
        sutAsProtocol.viewDidHideShimmer(
            fetchCardsResult: .failure(NSError(domain: "", code: NSURLErrorNotConnectedToInternet))
        )

        // then
        XCTAssertEqual(viewMock.showStubCallsCount, 1)
        XCTAssertEqual(viewMock.hideRightBarButtonCallsCount, 1)
        XCTAssertEqual(viewMock.showStubReceivedArguments, .noNetwork())
    }

    func test_viewDidHideShimmer_success_emptyCards_shouldShowNoCardsStub() throws {
        allureId(2397506, "Инициализируем заглушку в случае ошибки получения списка карт")
        allureId(2397501, "Инициализируем заглушку в случае получения пустого списка карт")

        // given
        prepareSut()

        // when
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success([]))

        // then
        XCTAssertEqual(viewMock.reloadCallsCount, 2)
        XCTAssertEqual(viewMock.hideStubCallsCount, 2)
        XCTAssertEqual(viewMock.showStubCallsCount, 1)
        XCTAssertEqual(viewMock.hideRightBarButtonCallsCount, 1)
        XCTAssertEqual(viewMock.showStubReceivedArguments, .noCardsInCardList())
    }

    func test_viewDidHideShimmer_success_shouldShowCards() throws {
        allureId(2397526, "Меняем состояние экрана карт на отображение полученного списка карт")
        allureId(2397528, "Определение ПС и банка-эмитента перед отображением карт")

        // given
        prepareSut()

        // when
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(buildActiveCardsCache()))

        // then
        XCTAssertEqual(viewMock.reloadCallsCount, 1)
        XCTAssertEqual(viewMock.hideStubCallsCount, 1)
        XCTAssertEqual(viewMock.showEditButtonCallsCount, 1)
        XCTAssertEqual(viewMock.reloadReceivedArguments?.isEmpty, false)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 1)
    }

    func test_viewDidTapCard_withCardListUseCase_shouldDoNothing() throws {
        // given
        prepareSut()
        let cards = buildActiveCardsCache()
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(cards))

        // when
        sutAsProtocol.viewDidTapCard(cardIndex: 0)

        // then
        XCTAssertEqual(output.cardListWillCloseAfterSelectingCallsCount, 0)
    }

    func test_viewDidTapCard_withCardListUseCase_shouldCloseScreen() {
        // given
        prepareSut(useCase: .cardPaymentList)
        let cards = buildActiveCardsCache()
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(cards))
        cards.forEach { sut.addNewCardDidReceive(result: .succeded($0)) }

        // when
        sutAsProtocol.viewDidTapCard(cardIndex: 0)

        // then
        XCTAssertEqual(output.cardListWillCloseAfterSelectingCallsCount, 1)
        XCTAssertEqual(output.cardListWillCloseAfterSelectingCallsCount, cards.count)
        XCTAssertEqual(viewMock.closeScreenCallsCount, 1)
    }

    func test_viewDidTapAddCardCell_shouldOpenAddNewCard() throws {
        allureId(2397529, "Переход на экран добавления карты")

        // given
        prepareSut()

        // when
        sutAsProtocol.viewDidTapAddCardCell()

        // then
        XCTAssertEqual(router.openAddNewCardCallsCount, 1)
    }

    func test_viewDidTapAddCardCell_shouldOpenCardPayment() throws {
        // given
        prepareSut(useCase: .cardPaymentList)

        // when
        sutAsProtocol.viewDidTapAddCardCell()

        // then
        XCTAssertEqual(router.openCardPaymentCallsCount, 1)
    }

    func test_getCardList_unknownCustomer_error_when_configurationIsCardList() {
        // given
        prepareSut()
        let noSuchCustomerErrorCode = 7

        // when
        sutAsProtocol.viewDidHideShimmer(
            fetchCardsResult: .failure(APIFailureError(errorCode: noSuchCustomerErrorCode))
        )
        if case let .noCardsInCardList(action) = viewMock.showStubReceivedArguments {
            action()
        }

        // then
        XCTAssertEqual(viewMock.showStubCallsCount, 1)
        XCTAssertEqual(viewMock.showStubReceivedArguments, .noCardsInCardList())
        XCTAssertEqual(router.openAddNewCardCallsCount, 1)
    }

    func test_getCardList_unkownCustomer_error_when_configurationIsCardPaymentList() {
        // given
        prepareSut(useCase: .cardPaymentList)
        let noSuchCustomerErrorCode = 7

        // when
        sutAsProtocol.viewDidHideShimmer(
            fetchCardsResult: .failure(APIFailureError(errorCode: noSuchCustomerErrorCode))
        )
        if case let .noCardsInCardPaymentList(action) = viewMock.showStubReceivedArguments {
            action()
        }

        // then
        XCTAssertEqual(viewMock.showStubCallsCount, 1)
        XCTAssertEqual(router.openCardPaymentCallsCount, 1)
    }

    func test_viewDidTapDelete() throws {
        allureId(2397531, "Отправляем запрос удаления карты при тапе на кнопку")
        allureId(2397536, "Уменьшение списка карт при успешном удаление карты")
        allureId(2397533, "Инициализируем заглушку в случае удаления последней карты")
        allureId(2397540, "Выход из состояния редактирования списка карт")
        allureId(2397539, "Промежуточное состояние при удалении карты")

        // given
        prepareSut()
        let cards = buildActiveCardsCache()
        let card = try XCTUnwrap(cards.first)
        let cardListCardToDelete = CardList.Card(from: card)

        cardsControllerMock.removeCardCompletionClosureInput = .success(RemoveCardPayload(cardId: cardListCardToDelete.id, cardStatus: .deleted))

        sut.viewDidHideShimmer(fetchCardsResult: .success(cards))
        sut.viewDidTapEditButton()

        // when
        sut.view(didTapDeleteOn: cardListCardToDelete)
        sut.viewDidHideRemovingCardSnackBar()

        // then
        let cardList = try XCTUnwrap(viewMock.reloadReceivedArguments?.getCardListFromCardsSection())
        let didDeleteCardFromView = cardList.count == (cards.count - 1) && !cardList.contains { $0.id == card.cardId }
        XCTAssertEqual(viewMock.showRemovingCardSnackBarCallsCount, 1)
        XCTAssertEqual(viewMock.disableViewUserInteractionCallsCount, 1)
        XCTAssertEqual(cardsControllerMock.removeCardCallsCount, 1)
        XCTAssertEqual(cardsControllerMock.removeCardReceivedArguments?.cardId, card.cardId)
        XCTAssertEqual(viewMock.hideLoadingSnackbarCallsCount, 1)
        XCTAssertTrue(didDeleteCardFromView)
        XCTAssertEqual(viewMock.showStubReceivedArguments, .noCardsInCardList())
        XCTAssertEqual(viewMock.hideRightBarButtonCallsCount, 1)
    }

    func test_addNewCardDidReceive() {
        allureId(2397518, "Отображение нового списка карт в случае успешного добавления без прохождения 3ds")
        allureId(2397502)
        // given
        prepareSut()
        let cards = buildActiveCardsCache()
        let paymentCard = PaymentCard.fake()
        sutAsProtocol.viewDidHideShimmer(fetchCardsResult: .success(cards))

        // when
        sut.addNewCardDidReceive(result: .succeded(paymentCard))

        // then
        XCTAssertEqual(viewMock.showAddedCardSnackbarCallsCount, 1)
    }

    func test_viewDidShowAddedCardSnackbar() {
        allureId(2397518, "Отображение нового списка карт в случае успешного добавления без прохождения 3ds")
        allureId(2397502)
        // given
        prepareSut()

        // when
        sut.viewDidShowAddedCardSnackbar()

        // then
        let counter = viewMock.showDoneEditingButtonCallsCount + viewMock.showEditButtonCallsCount
        XCTAssertTrue(counter > 0)
        XCTAssertEqual(viewMock.hideStubCallsCount, 1)
        XCTAssertEqual(viewMock.reloadCallsCount, 1)
    }

    func test_viewDidShowAddedCardSnackbar_shows_doneEditingButton() {
        // given
        prepareSut()
        sut.viewDidHideShimmer(fetchCardsResult: .success(buildActiveCardsCache()))
        // setting screenState to .editingCards
        sut.viewDidTapEditButton()

        // resetting calls state
        viewMock.showDoneEditingButtonCallsCount = .zero
        viewMock.hideStubCallsCount = .zero
        viewMock.reloadCallsCount = .zero

        // when
        sut.viewDidShowAddedCardSnackbar()

        // then
        XCTAssertEqual(viewMock.showDoneEditingButtonCallsCount, 1)
        XCTAssertEqual(viewMock.hideStubCallsCount, 1)
        XCTAssertEqual(viewMock.reloadCallsCount, 1)
    }

    func test_viewDidShowAddedCardSnackbar_shows_editButton() {
        // given
        prepareSut()

        // when
        sut.viewDidShowAddedCardSnackbar()

        // then
        XCTAssertEqual(viewMock.showEditButtonCallsCount, 1)
        XCTAssertEqual(viewMock.hideStubCallsCount, 1)
        XCTAssertEqual(viewMock.reloadCallsCount, 1)
    }

    func test_viewDoesNotShowCards_whenAddCardResultIsCancelled() {
        // given
        prepareSut()

        // when
        sut.addNewCardDidReceive(result: .cancelled)

        // then
        XCTAssertEqual(viewMock.showAddedCardSnackbarCallsCount, 0)
    }

    func test_viewDoesNotShowCards_whenAddCardResultIsFailed() {
        // given
        prepareSut()

        // when
        sut.addNewCardDidReceive(result: .failed(ErrorStub()))

        // then
        XCTAssertEqual(viewMock.showAddedCardSnackbarCallsCount, 0)
    }

    func test_viewHideShimmer_whenCardsAreNotEmpty() {
        // given
        prepareSut()
        sut.addNewCardDidReceive(result: .succeded(.fake()))

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.hideShimmerCallsCount, 1)
    }

    // MARK: Private

    private func prepareSut(useCase: CardListScreenConfiguration.UseCase = .cardList) {
        sut = CardListPresenter(
            screenConfiguration: buildScreenConfiguration(useCase: useCase),
            cardsController: cardsControllerMock,
            router: router,
            imageResolver: paymentSystemImageResolverMock,
            bankResolver: bankResolverMock,
            paymentSystemResolver: paymentSystemResolverMock,
            output: output
        )

        sut.view = viewMock
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
