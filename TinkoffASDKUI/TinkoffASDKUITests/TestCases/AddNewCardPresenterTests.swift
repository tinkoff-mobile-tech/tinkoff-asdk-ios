//
//  AddNewCardPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 28.12.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation
import XCTest

final class AddNewCardPresenterTests: XCTestCase {

    // MARK: - Dependencies

    var sut: AddNewCardPresenter!
    var cardFieldFactoryMock: MockCardFieldFactory!
    var networkingMock: MockAddNewCardNetworking!
    var viewMock: MockIAddNewCardView!
    var addNewCardOutputMock: MockAddNewCardOutput!
    var cardFieldPresenterMock: MockCardFieldPresenter!
    var sutAsProtocol: IAddNewCardPresenter { sut }

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        let networkingMock = MockAddNewCardNetworking()
        let cardFieldFactoryMock = MockCardFieldFactory()
        let mockView = MockIAddNewCardView()
        let cardFieldPresenterMock = MockCardFieldPresenter()
        let addNewCardOutputMock = MockAddNewCardOutput()

        let presenter = AddNewCardPresenter(
            networking: networkingMock,
            output: addNewCardOutputMock
        )

        presenter.view = mockView

        sut = presenter
        self.cardFieldFactoryMock = cardFieldFactoryMock
        self.networkingMock = networkingMock
        viewMock = mockView
        self.cardFieldPresenterMock = cardFieldPresenterMock
        self.addNewCardOutputMock = addNewCardOutputMock
    }

    override func tearDown() {
        sut = nil
        cardFieldFactoryMock = nil
        networkingMock = nil
        viewMock = nil
        cardFieldPresenterMock = nil
        addNewCardOutputMock = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad() throws {
        // when
        sutAsProtocol.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.reloadCollectionCallCounter, 1)
        XCTAssertEqual(viewMock.disableAddButtonCallCounter, 1)
    }

    func test_viewAddCardTapped_addCard_success() throws {
        // given
        let paymentCard = buildPaymentCard()
        let addCardExpectation = expectation(description: #function + "addCard")
        let addNewCardResultSuccess = expectation(description: #function + "addNewCardResultSuccess")

        cardFieldPresenterMock.validateWholeFormStub = {
            CardFieldValidationResult.initWithAllFieldsValid()
        }

        networkingMock.addCardStub = { input in
            input.resultCompletion(.success(card: paymentCard))
            addCardExpectation.fulfill()
        }

        addNewCardOutputMock.addingNewCardCompletedStub = { result in
            if case AddNewCardResult.success = result {
                addNewCardResultSuccess.fulfill()
            }
        }

        sutAsProtocol.viewDidLoad()

        // when
        sutAsProtocol.viewAddCardTapped(cardData: buildAddCardData())
        wait(for: [addCardExpectation, addNewCardResultSuccess], timeout: .testTimeout)

        // then
        XCTAssertEqual(viewMock.showLoadingStateCallCounter, 1)
        XCTAssertEqual(networkingMock.addCardCallCounter, 1)
        XCTAssertEqual(viewMock.hideLoadingStateCallCounter, 1)

        // success flow
        XCTAssertEqual(viewMock.closeScreenCallCounter, 1)
        XCTAssertEqual(addNewCardOutputMock.addingNewCardCompletedCallCounter, 1)
    }

    // MARK: - addCard() failure flows

    func test_viewAddCardTapped_addCard_failure_genericError() throws {
        // given
        let addCardExpectation = expectation(description: #function + "addCard")

        cardFieldPresenterMock.validateWholeFormStub = {
            CardFieldValidationResult.initWithAllFieldsValid()
        }

        networkingMock.addCardStub = { input in
            input.resultCompletion(.failure(error: TestsError.basic))
            addCardExpectation.fulfill()
        }

        // triggers setting inner cardfield factory result
        sutAsProtocol.viewDidLoad()

        // when
        sutAsProtocol.viewAddCardTapped(cardData: buildAddCardData())
        wait(for: [addCardExpectation], timeout: .testTimeout)

        // then
        XCTAssertEqual(viewMock.showLoadingStateCallCounter, 1)
        XCTAssertEqual(networkingMock.addCardCallCounter, 1)
        XCTAssertEqual(viewMock.hideLoadingStateCallCounter, 1)

        // failure flow
        XCTAssertEqual(viewMock.showOkNativeAlertCallCounter, 1)
    }

    func test_viewAddCardTapped_addCard_failure_userCancelledCardAddingError() throws {
        // given
        let addCardExpectation = expectation(description: #function + "addCard")

        cardFieldPresenterMock.validateWholeFormStub = {
            CardFieldValidationResult.initWithAllFieldsValid()
        }

        networkingMock.addCardStub = { input in
            input.resultCompletion(.cancelled)
            addCardExpectation.fulfill()
        }

        sutAsProtocol.viewDidLoad()

        // when
        sutAsProtocol.viewAddCardTapped(cardData: buildAddCardData())
        wait(for: [addCardExpectation], timeout: .testTimeout)

        // then
        XCTAssertEqual(viewMock.showLoadingStateCallCounter, 1)
        XCTAssertEqual(networkingMock.addCardCallCounter, 1)
        XCTAssertEqual(viewMock.hideLoadingStateCallCounter, 1)

        // failure flow
        XCTAssertEqual(viewMock.closeScreenCallCounter, 1)
    }

    func test_viewAddCardTapped_addCard_failure_alreadyHasSuchCardError() throws {
        // given
        let addCardExpectation = expectation(description: #function + "addCard")
        let alreadyHasSuchCardErrorCode = 510

        cardFieldPresenterMock.validateWholeFormStub = {
            CardFieldValidationResult.initWithAllFieldsValid()
        }

        networkingMock.addCardStub = { input in
            let error = APIError.failure(APIFailureError(errorCode: alreadyHasSuchCardErrorCode))
            input.resultCompletion(.failure(error: error))
            addCardExpectation.fulfill()
        }

        sutAsProtocol.viewDidLoad()

        // when
        sutAsProtocol.viewAddCardTapped(cardData: buildAddCardData())
        wait(for: [addCardExpectation], timeout: .testTimeout)

        // then
        XCTAssertEqual(viewMock.showLoadingStateCallCounter, 1)
        XCTAssertEqual(networkingMock.addCardCallCounter, 1)
        XCTAssertEqual(viewMock.hideLoadingStateCallCounter, 1)

        // failure flow
        XCTAssertEqual(viewMock.showOkNativeAlertCallCounter, 1)
    }
}

extension AddNewCardPresenterTests {

    func buildPaymentCard() -> PaymentCard {
        PaymentCard(
            pan: "220138******0104",
            cardId: "458542919",
            status: .active,
            parentPaymentId: nil,
            expDate: "1129"
        )
    }

    func buildAddCardData() -> CardData {
        CardData(cardNumber: "", expiration: "", cvc: "")
    }
}

extension CardFieldValidationResult {

    static func initWithAllFieldsValid() -> Self {
        Self(cardNumberIsValid: true, expirationIsValid: true, cvcIsValid: true)
    }
}
