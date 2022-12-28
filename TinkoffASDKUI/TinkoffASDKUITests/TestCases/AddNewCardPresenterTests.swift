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

    func test_viewDidLoad() throws {
        // given
        let dependencies = buildDependecies()
        // when
        dependencies.sutAsProtocol.viewDidLoad()

        // then
        XCTAssertEqual(dependencies.viewMock.reloadCollectionCallCounter, 1)
        XCTAssertEqual(dependencies.viewMock.disableAddButtonCallCounter, 1)
    }

    func test_viewAddCardTapped_addCard_success() throws {
        // given
        let dependencies = buildDependecies()
        let networking = dependencies.networkingMock
        let paymentCard = buildPaymentCard()
        let addCardExpectation = expectation(description: #function + "addCard")
        let notifyAddedCardExpectation = expectation(description: #function + "notifyAddedCard")
        let cardFieldPresenterMock = dependencies.cardFieldPresenterMock

        cardFieldPresenterMock.validateWholeFormStub = {
            CardFieldPresenter.ValidationResult.initWithAllFieldsValid()
        }

        networking.addCardStub = { input in
            input.resultCompletion(.success(paymentCard))
            addCardExpectation.fulfill()
        }

        dependencies.viewMock.notifyAddedStub = { card in
            XCTAssertEqual(card, paymentCard)
            notifyAddedCardExpectation.fulfill()
        }

        // triggers setting inner cardfield factory result
        dependencies.sutAsProtocol.viewDidLoad()

        // when
        dependencies.sutAsProtocol.viewAddCardTapped()
        wait(for: [addCardExpectation, notifyAddedCardExpectation], timeout: .testTimeout)

        // then
        XCTAssertEqual(dependencies.viewMock.showLoadingStateCallCounter, 1)
        XCTAssertEqual(dependencies.networkingMock.addCardCallCounter, 1)
        XCTAssertEqual(dependencies.viewMock.hideLoadingStateCallCounter, 1)

        // success flow
        XCTAssertEqual(dependencies.viewMock.closeScreenCallCounter, 1)
        XCTAssertEqual(dependencies.viewMock.notifyAddedCallCounter, 1)
    }

    // MARK: - addCard() failure flows

    func test_viewAddCardTapped_addCard_failure_genericError() throws {
        // given
        let dependencies = buildDependecies()
        let networking = dependencies.networkingMock
        let addCardExpectation = expectation(description: #function + "addCard")
        let cardFieldPresenterMock = dependencies.cardFieldPresenterMock

        cardFieldPresenterMock.validateWholeFormStub = {
            CardFieldPresenter.ValidationResult.initWithAllFieldsValid()
        }

        networking.addCardStub = { input in
            input.resultCompletion(.failure(TestsError.basic))
            addCardExpectation.fulfill()
        }

        // triggers setting inner cardfield factory result
        dependencies.sutAsProtocol.viewDidLoad()

        // when
        dependencies.sutAsProtocol.viewAddCardTapped()
        wait(for: [addCardExpectation], timeout: .testTimeout)

        // then
        XCTAssertEqual(dependencies.viewMock.showLoadingStateCallCounter, 1)
        XCTAssertEqual(dependencies.networkingMock.addCardCallCounter, 1)
        XCTAssertEqual(dependencies.viewMock.hideLoadingStateCallCounter, 1)

        // failure flow
        XCTAssertEqual(dependencies.viewMock.showGenericErrorNativeAlertCallCounter, 1)
    }

    func test_viewAddCardTapped_addCard_failure_userCancelledCardAddingError() throws {
        // given
        let dependencies = buildDependecies()
        let networking = dependencies.networkingMock
        let addCardExpectation = expectation(description: #function + "addCard")
        let cardFieldPresenterMock = dependencies.cardFieldPresenterMock

        cardFieldPresenterMock.validateWholeFormStub = {
            CardFieldPresenter.ValidationResult.initWithAllFieldsValid()
        }

        networking.addCardStub = { input in
            input.resultCompletion(.failure(AcquiringUiSdkError.userCancelledCardAdding))
            addCardExpectation.fulfill()
        }

        // triggers setting inner cardfield factory result
        dependencies.sutAsProtocol.viewDidLoad()

        // when
        dependencies.sutAsProtocol.viewAddCardTapped()
        wait(for: [addCardExpectation], timeout: .testTimeout)

        // then
        XCTAssertEqual(dependencies.viewMock.showLoadingStateCallCounter, 1)
        XCTAssertEqual(dependencies.networkingMock.addCardCallCounter, 1)
        XCTAssertEqual(dependencies.viewMock.hideLoadingStateCallCounter, 1)

        // failure flow
        XCTAssertEqual(dependencies.viewMock.closeScreenCallCounter, 1)
    }

    func test_viewAddCardTapped_addCard_failure_alreadyHasSuchCardError() throws {
        // given
        let dependencies = buildDependecies()
        let networking = dependencies.networkingMock
        let addCardExpectation = expectation(description: #function + "addCard")
        let alreadyHasSuchCardErrorCode = 510
        let cardFieldPresenterMock = dependencies.cardFieldPresenterMock

        cardFieldPresenterMock.validateWholeFormStub = {
            CardFieldPresenter.ValidationResult.initWithAllFieldsValid()
        }

        networking.addCardStub = { input in
            let error = APIError.failure(APIFailureError(errorCode: alreadyHasSuchCardErrorCode))
            input.resultCompletion(.failure(error))
            addCardExpectation.fulfill()
        }

        // triggers setting inner cardfield factory result
        dependencies.sutAsProtocol.viewDidLoad()

        // when
        dependencies.sutAsProtocol.viewAddCardTapped()
        wait(for: [addCardExpectation], timeout: .testTimeout)

        // then
        XCTAssertEqual(dependencies.viewMock.showLoadingStateCallCounter, 1)
        XCTAssertEqual(dependencies.networkingMock.addCardCallCounter, 1)
        XCTAssertEqual(dependencies.viewMock.hideLoadingStateCallCounter, 1)

        // failure flow
        XCTAssertEqual(dependencies.viewMock.showAlreadySuchCardErrorNativeAlertCallCounter, 1)
    }
}

extension AddNewCardPresenterTests {

    struct Dependencies {
        let sut: AddNewCardPresenter
        let cardFieldFactoryMock: MockCardFieldFactory
        let networkingMock: MockAddNewCardNetworking
        let viewMock: MockIAddNewCardView
        let cardFieldPresenterMock: MockCardFieldPresenter

        var sutAsProtocol: IAddNewCardPresenter { sut }
    }

    func buildDependecies() -> Dependencies {
        let mockFactory = MockCardFieldFactory()
        let mockNetworking = MockAddNewCardNetworking()
        let mockView = MockIAddNewCardView()
        let cardFieldPresenterMock = MockCardFieldPresenter()

        mockFactory.assembleCardFieldConfigStub = { input in
            .init(configuration: nil, presenter: cardFieldPresenterMock)
        }

        let presenter = AddNewCardPresenter(
            cardFieldFactory: mockFactory,
            networking: mockNetworking
        )

        presenter.view = mockView

        return Dependencies(
            sut: presenter,
            cardFieldFactoryMock: mockFactory,
            networkingMock: mockNetworking,
            viewMock: mockView,
            cardFieldPresenterMock: cardFieldPresenterMock
        )
    }

    func buildPaymentCard() -> PaymentCard {
        PaymentCard(
            pan: "220138******0104",
            cardId: "458542919",
            status: .active,
            parentPaymentId: nil,
            expDate: "1129"
        )
    }
}
