//
//  CardPaymentPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 19.05.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardPaymentPresenterTests: BaseTestCase {

    var sut: CardPaymentPresenter!

    // MARK: Mocks

    var viewMock: CardPaymentViewControllerInputMock!
    var routerMock: CardPaymentRouterMock!
    var outputMock: CardPaymentPresenterModuleOutputMock!
    var cardListOutputMock: CardListPresenterOutputMock!
    var cardsControllerMock: CardsControllerMock!
    var paymentControllerMock: PaymentControllerMock!
    var mainDispatchQueueMock: DispatchQueueMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        routerMock = nil
        outputMock = nil
        cardListOutputMock = nil
        cardsControllerMock = nil
        paymentControllerMock = nil
        mainDispatchQueueMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: Tests

    func test_viewDidLoad_with_initialActiveCards() {
        // given
        setupSut(activeCards: createActiveCardsArray())
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }
    
    func test_viewDidLoad_with_initialActiveCardsNil_and_cardsControllerNil() {
        // given
        setupSut(cardsController: nil)
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.showActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.showActivityIndicatorReceivedArguments, .xlYellow)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }
    
    func test_viewDidLoad_with_initialActiveCardsNil_success() {
        // given
        cardsControllerMock.getActiveCardsStub = { completion in
            completion(.success(self.createActiveCardsArray()))
        }
        mainDispatchQueueMock.asyncWorkShouldCalls = true
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.showActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.showActivityIndicatorReceivedArguments, .xlYellow)
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(viewMock.hideActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }
    
    func test_viewDidLoad_with_initialActiveCardsNil_failure() {
        // given
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        cardsControllerMock.getActiveCardsStub = { completion in
            completion(.failure(error))
        }
        mainDispatchQueueMock.asyncWorkShouldCalls = true
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.showActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.showActivityIndicatorReceivedArguments, .xlYellow)
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(viewMock.hideActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }
    
    func test_cellType_when_initialActiveCards() {
        // given
        setupSut(activeCards: createActiveCardsArray())
        sut.viewDidLoad()
        
        // when
        let types = [0, 1, 2, 3].map { sut.cellType(for: $0) }
        
        // then
        types.enumerated().forEach { index, type in
            switch type {
            case .savedCard where index == 0: break
            case .getReceipt where index == 1: break
            case .emailField where index == 2: break
            case .payButton where index == 3: break
            default: XCTFail("Wrong types of presenters")
            }
        }
    }
    
    func test_cellType_when_initialActiveCards_with_userEmailNil() {
        // given
        setupSut(activeCards: createActiveCardsArray(), paymentFlow: .fake())
        sut.viewDidLoad()
        
        // when
        let types = [0, 1, 2].map { sut.cellType(for: $0) }
        
        // then
        types.enumerated().forEach { index, type in
            switch type {
            case .savedCard where index == 0: break
            case .getReceipt where index == 1: break
            case .payButton where index == 2: break
            default: XCTFail("Wrong types of presenters")
            }
        }
    }
    
    func test_cellType_when_initialActiveCardsEmpty() {
        // given
        setupSut(activeCards: createActiveCardsEmptyArray())
        sut.viewDidLoad()
        
        // when
        let types = [0, 1, 2, 3].map { sut.cellType(for: $0) }
        
        // then
        types.enumerated().forEach { index, type in
            switch type {
            case .cardField where index == 0: break
            case .getReceipt where index == 1: break
            case .emailField where index == 2: break
            case .payButton where index == 3: break
            default: XCTFail("Wrong types of presenters")
            }
        }
    }
    
    func test_closeButtonPressed() {
        // when
        sut.closeButtonPressed()
        
        // then
        XCTAssertEqual(routerMock.closeScreenCallsCount, 1)
    }
    
    func test_numberOfRows_with_activeCards_with_userEmailNil() {
        // given
        setupSut(activeCards: createActiveCardsArray(), paymentFlow: .fake())
        sut.viewDidLoad()
        
        // when
        let numberOfRows = sut.numberOfRows()
        
        // then
        XCTAssertEqual(numberOfRows, 3)
    }
    
    func test_numberOfRows_with_activeCards() {
        // given
        setupSut(activeCards: createActiveCardsArray())
        sut.viewDidLoad()
        
        // when
        let numberOfRows = sut.numberOfRows()
        
        // then
        XCTAssertEqual(numberOfRows, 4)
    }
    
    func test_numberOfRows_with_emptyActiveCards() {
        // given
        setupSut(activeCards: createActiveCardsEmptyArray())
        sut.viewDidLoad()
        
        // when
        let numberOfRows = sut.numberOfRows()
        
        // then
        XCTAssertEqual(numberOfRows, 4)
    }
}

// MARK: - Private

extension CardPaymentPresenterTests {
    private func setupSut(
        cardsController: CardsControllerMock? = CardsControllerMock(),
        activeCards: [PaymentCard]? = nil,
        paymentFlow: PaymentFlow = .fullRandom,
        amount: Int64 = 100,
        isCardFieldScanButtonNeeded: Bool = false
    ) {
        viewMock = CardPaymentViewControllerInputMock()
        routerMock = CardPaymentRouterMock()
        outputMock = CardPaymentPresenterModuleOutputMock()
        cardListOutputMock = CardListPresenterOutputMock()
        cardsControllerMock = cardsController
        paymentControllerMock = PaymentControllerMock()
        mainDispatchQueueMock = DispatchQueueMock()

        sut = CardPaymentPresenter(
            router: routerMock,
            output: outputMock,
            cardListOutput: cardListOutputMock,
            cardsController: cardsControllerMock,
            paymentController: paymentControllerMock,
            mainDispatchQueue: mainDispatchQueueMock,
            activeCards: activeCards,
            paymentFlow: paymentFlow,
            amount: amount,
            isCardFieldScanButtonNeeded: isCardFieldScanButtonNeeded
        )

        sut.view = viewMock
    }
    
    private func createActiveCardsEmptyArray() -> [PaymentCard] {
        []
    }
    
    private func createActiveCardsArray() -> [PaymentCard] {
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
}
