//
//  CardsControllerTests.swift
//  Pods
//
//  Created by Ivan Glushko on 30.03.2023.
//

import XCTest

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardsControllerTests: BaseTestCase {

    var sut: CardsController!

    // Mocks

    var cardServiceMock: CardServiceMock!
    var addCardControllerMock: AddCardControllerMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        cardServiceMock = CardServiceMock()
        addCardControllerMock = AddCardControllerMock()

        sut = CardsController(
            cardService: cardServiceMock,
            addCardController: addCardControllerMock
        )
    }

    override func tearDown() {
        cardServiceMock = nil
        addCardControllerMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_GetCardList_invoked() {
        allureId(2397495, "Отправляем запрос v2/GetCardList в случае успешного ответа v2/GetAddCardState по 3ds v1 flow")
        allureId(2397497)
        allureId(2397510)
        allureId(2397532)

        // given
        cardServiceMock.getCardListReturnValue = CancellableMock()
        addCardControllerMock.underlyingCustomerKey = "key"
        addCardControllerMock.addCardCompletionStub = .succeded(.fake(status: .authorized))

        // when
        sut.addCard(options: CardOptions.fake(), completion: { _ in })

        // then
        XCTAssertEqual(cardServiceMock.getCardListCallsCount, 1)
    }

    func test_addCard_cancelled() {
        allureId(2397499, "Успешно обрабатываем отмену в случае статуса отмены web-view")

        // given
        addCardControllerMock.underlyingCustomerKey = "key"
        addCardControllerMock.addCardCompletionStub = .cancelled
        var mappedResultToCancelled = false

        // when
        sut.addCard(options: CardOptions.fake(), completion: { result in
            guard case .cancelled = result else { return }
            mappedResultToCancelled = true
        })

        // then
        XCTAssertEqual(addCardControllerMock.addCardCallsCount, 1)
        XCTAssertTrue(mappedResultToCancelled)
    }

    func test_addCard_error() {
        allureId(2397521, "Успешно обрабатываем ошибку в случае ошибки запроса v2/GetAddCardState")
        allureId(2397515)

        // given
        addCardControllerMock.underlyingCustomerKey = "key"
        addCardControllerMock.addCardCompletionStub = .failed(TestsError.basic)
        var mappedResultToFailure = false

        // when
        sut.addCard(options: CardOptions.fake(), completion: { result in
            guard case let .failed(error) = result, error is TestsError else { return }
            mappedResultToFailure = true
        })

        // then
        XCTAssertEqual(addCardControllerMock.addCardCallsCount, 1)
        XCTAssertTrue(mappedResultToFailure)
        XCTAssertEqual(cardServiceMock.getCardListCallsCount, .zero)
    }

    func test_addCard_success_GetCardList_error() {
        allureId(2397522, "Успешно обрабатываем ошибку в случае ошибки запроса v2/GetCardList")
        allureId(2397516)

        // given
        cardServiceMock.getCardListReturnValue = CancellableMock()
        cardServiceMock.getCardListCompletionStub = .failure(TestsError.basic)
        addCardControllerMock.underlyingCustomerKey = "key"
        addCardControllerMock.addCardCompletionStub = .succeded(.fake(status: .authorized))
        var didReturnError = false

        // when
        sut.addCard(options: CardOptions.fake(), completion: { result in
            if case let .failed(error) = result, error is TestsError {
                didReturnError = true
            }
        })

        // then
        XCTAssertEqual(cardServiceMock.getCardListCallsCount, 1)
        XCTAssertTrue(didReturnError)
    }
}
