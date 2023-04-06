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

    func test_addCard_success() throws {
        allureId(2397514, "Инициалилизируем 3DS web-view v1 по ответу v2/AttachCard")
        allureId(2397518, "Отображение нового списка карт в случае успешного добавления без прохождения 3ds")
        allureId(2397509, "Отпавляем запрос v2/AddCard при тапе на кнопку")
        allureId(2397535)
        // given
        let paymentCard = PaymentCard.fake()
        cardFieldPresenterMock.bootstrap()
        cardFieldPresenterMock.validateWholeFormReturnValue = .allValid()

        cardsControllerMock.addCardStub = { options, completion in
            completion(.succeded(paymentCard))
        }

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

        cardsControllerMock.addCardStub = { options, completion in
            completion(.cancelled)
        }

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

        cardsControllerMock.addCardStub = { options, completion in
            completion(.failed(error))
        }

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

        cardsControllerMock.addCardStub = { options, completion in
            completion(.failed(NSError(domain: "", code: 510)))
        }

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
