//
//  AddNewCardPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AddNewCardPresenterTests: BaseTestCase {

    var sut: AddNewCardPresenter!

    // Mocks
    var onViewWasClosedStub: ((AddCardResult) -> Void)?
    var cardsControllerMock: CardsControllerMock!
    var outputMock: AddNewCardPresenterOutputMock!
    var cardFieldPresenterMock: CardFieldViewOutputMock!
    var viewMock: AddNewCardViewMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        cardsControllerMock = CardsControllerMock()
        outputMock = AddNewCardPresenterOutputMock()
        cardFieldPresenterMock = CardFieldViewOutputMock()
        viewMock = AddNewCardViewMock()

        sut = AddNewCardPresenter(
            cardsController: cardsControllerMock,
            output: outputMock,
            onViewWasClosed: { [weak self] result in
                self?.onViewWasClosedStub?(result)
            },
            cardFieldPresenter: cardFieldPresenterMock
        )

        sut.view = viewMock
    }

    override func tearDown() {
        cardsControllerMock = nil
        outputMock = nil
        cardFieldPresenterMock = nil
        viewMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad() {
        // when
        sut.viewDidLoad()
        // then
        XCTAssertEqual(viewMock.reloadCollectionCallsCount, 1)
        XCTAssertEqual(viewMock.reloadCollectionReceivedArguments, [.cardField])
    }

    func test_viewDidAppear_when_notLoading() {
        // when
        sut.viewDidAppear()
        // then
        XCTAssertEqual(viewMock.activateCardFieldCallsCount, 1)
    }

    func test_viewDidAppear_when_loading() {
        // given
        viewMock.underlyingIsLoading = true

        // when
        sut.viewDidAppear()

        // then
        XCTAssertEqual(viewMock.activateCardFieldCallsCount, 0)
    }

    func test_viewWasClosed() {
        // given
        var calledOnViewWasClosedWithCancelled = false
        onViewWasClosedStub = {
            if case AddCardResult.cancelled = $0 {
                calledOnViewWasClosedWithCancelled = true
            }
        }

        // when
        sut.viewWasClosed()
        // then
        XCTAssertEqual(outputMock.addNewCardWasClosedCallsCount, 1)
        XCTAssertEqual(outputMock.addNewCardWasClosedReceivedArguments, .cancelled)
        XCTAssertTrue(calledOnViewWasClosedWithCancelled)
    }

    func test_cardFielViewPresenter() {
        // when
        let presenter = sut.cardFieldViewPresenter()
        // then
        XCTAssert(presenter === cardFieldPresenterMock)
    }

    func test_scanButtonPressed() {
        // given
        viewMock.showCardScannerCompletionStub = ("42223142353", "02/29", "111")
        // when
        sut.scanButtonPressed()
        // then
        let updatedFields = cardFieldPresenterMock.setTextFieldTypeReceivedInvocations.map { $0.0 }
        XCTAssertEqual(viewMock.showCardScannerCallsCount, 1)
        XCTAssertEqual(cardFieldPresenterMock.setTextFieldTypeCallsCount, 3)
        XCTAssertEqual(updatedFields, [.cardNumber, .expiration, .cvc])
    }

    func test_view_setup() {
        // given
        let viewMock = AddNewCardViewMock()
        // when
        sut.view = viewMock
        // then
        XCTAssertEqual(viewMock.setAddButtonCallCounter, 1)
        XCTAssertEqual(viewMock.setAddButtonArguments?.enabled, false)
        XCTAssertEqual(viewMock.setAddButtonArguments?.animated, false)
    }

    func test_addCard_success() throws {
        allureId(2397514, "Инициалилизируем 3DS web-view v1 по ответу v2/AttachCard")
        allureId(2397518, "Отображение нового списка карт в случае успешного добавления без прохождения 3ds")
        allureId(2397509, "Отпавляем запрос v2/AddCard при тапе на кнопку")
        allureId(2397535)
        allureId(2397538, "Переход в промежуточное состояние добавления карты")

        // given
        let paymentCard = PaymentCard.fake()
        cardFieldPresenterMock.bootstrap()
        cardFieldPresenterMock.validateWholeFormReturnValue = .allValid()

        cardsControllerMock.addCardCompletionClosureInput = .succeded(paymentCard)

        // when
        sut.cardFieldViewAddCardTapped()

        // then
        XCTAssertEqual(viewMock.showLoadingStateCallsCount, 1)
        XCTAssertEqual(cardsControllerMock.addCardCallsCount, 1)
        XCTAssertEqual(viewMock.hideLoadingStateCallsCount, 1)
        XCTAssertEqual(outputMock.addNewCardDidReceiveCallsCount, 1)
        let result = try XCTUnwrap(outputMock.addNewCardDidReceiveReceivedArguments)
        guard case AddCardResult.succeded = result else {
            XCTFail()
            return
        }

        XCTAssertEqual(viewMock.closeScreenCallsCount, 1)
    }

    func test_addCard_cancelled() {
        allureId(2397499, "Успешно обрабатываем отмену в случае статуса отмены web-view")
        // given
        cardFieldPresenterMock.bootstrap()
        cardFieldPresenterMock.validateWholeFormReturnValue = .allValid()

        cardsControllerMock.addCardCompletionClosureInput = .cancelled

        // when
        sut.cardFieldViewAddCardTapped()

        // then
        XCTAssertEqual(viewMock.closeScreenCallsCount, 1)
        XCTAssertEqual(viewMock.showLoadingStateCallsCount, 1)
        XCTAssertEqual(cardsControllerMock.addCardCallsCount, 1)
        XCTAssertEqual(viewMock.hideLoadingStateCallsCount, 1)
        XCTAssertEqual(outputMock.addNewCardDidReceiveCallsCount, 1)
    }

    func test_addCard_generic_error() {
        allureId(2397498, "Успешно обрабатываем ошибку в случае ошибки web-view")
        allureId(2397519)
        allureId(2397520)
        allureId(2397521)
        allureId(2397522)
        allureId(2397523)
        allureId(2397503)
        allureId(2397504)
        allureId(2397516)
        // given
        let error = TestsError.basic
        cardFieldPresenterMock.bootstrap()
        cardFieldPresenterMock.validateWholeFormReturnValue = .allValid()

        cardsControllerMock.addCardCompletionClosureInput = .failed(error)

        // when
        sut.cardFieldViewAddCardTapped()

        // then
        XCTAssertEqual(viewMock.showOkNativeAlertCallsCount, 1)
        XCTAssertEqual(viewMock.showLoadingStateCallsCount, 1)
        XCTAssertEqual(cardsControllerMock.addCardCallsCount, 1)
        XCTAssertEqual(viewMock.hideLoadingStateCallsCount, 1)
        XCTAssertEqual(outputMock.addNewCardDidReceiveCallsCount, 1)
        XCTAssertEqual(viewMock.showOkNativeAlertReceivedArguments?.title, Loc.CommonAlert.SomeProblem.title)
        XCTAssertEqual(viewMock.showOkNativeAlertReceivedArguments?.message, Loc.CommonAlert.SomeProblem.description)
        XCTAssertEqual(viewMock.showOkNativeAlertReceivedArguments?.buttonTitle, Loc.CommonAlert.button)
    }

    func test_addCard_510_error() {
        // given
        cardFieldPresenterMock.bootstrap()
        cardFieldPresenterMock.validateWholeFormReturnValue = .allValid()

        cardsControllerMock.addCardCompletionClosureInput = .failed(NSError(domain: "", code: 510))

        // when
        sut.cardFieldViewAddCardTapped()

        // then
        XCTAssertEqual(viewMock.showOkNativeAlertCallsCount, 1)
        XCTAssertEqual(viewMock.showOkNativeAlertReceivedArguments?.title, Loc.CommonAlert.AddCard.title)
        XCTAssertEqual(viewMock.showOkNativeAlertReceivedArguments?.buttonTitle, Loc.CommonAlert.button)
    }

    func test_cardFieldViewAddCardTapped_notValid() {
        // given
        cardFieldPresenterMock.bootstrap()
        cardFieldPresenterMock.validateWholeFormReturnValue = .notValid()

        // when
        sut.cardFieldViewAddCardTapped()

        // then
        XCTAssertEqual(viewMock.showLoadingStateCallsCount, 0)
        XCTAssertEqual(cardsControllerMock.addCardCallsCount, 0)
        XCTAssertEqual(viewMock.hideLoadingStateCallsCount, 0)
        XCTAssertEqual(outputMock.addNewCardDidReceiveCallsCount, 0)
    }

    func test_setAddButton_state_when_being_changed() {
        allureId(2559471, "Кнопка Добавить неактивна")

        // given
        var validationResult = CardFieldValidationResult.allValid()

        // when
        sut.cardFieldValidationResultDidChange(result: validationResult)

        // then
        XCTAssertEqual(viewMock.setAddButtonCallCounter, 2)
        XCTAssertEqual(viewMock.setAddButtonArguments?.enabled, true)

        // when
        validationResult.cardNumberIsValid = false
        sut.cardFieldValidationResultDidChange(result: validationResult)

        // then
        XCTAssertEqual(viewMock.setAddButtonCallCounter, 3)
        XCTAssertEqual(viewMock.setAddButtonArguments?.enabled, false)
    }

    func test_setAddButton_state_when_field_are_valid() {
        allureId(2559428, "Кнопка Добавить становится активной, если данные карты валидны")

        // given
        XCTAssertEqual(viewMock.setAddButtonCallCounter, 1)
        XCTAssertEqual(viewMock.setAddButtonArguments?.enabled, false)

        // when
        sut.cardFieldValidationResultDidChange(result: .allValid())

        // then
        XCTAssertEqual(viewMock.setAddButtonCallCounter, 2)
        XCTAssertEqual(viewMock.setAddButtonArguments?.enabled, true)
    }
}

extension CardFieldValidationResult {

    static func allValid() -> Self {
        CardFieldValidationResult(
            cardNumberIsValid: true,
            expirationIsValid: true,
            cvcIsValid: true
        )
    }

    static func notValid() -> Self {
        CardFieldValidationResult(cardNumberIsValid: false)
    }
}
