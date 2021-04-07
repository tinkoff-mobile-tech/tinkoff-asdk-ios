//
//
//  DefaultCardsControllerTests.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


@testable import TinkoffASDKUI
import TinkoffASDKCore
import XCTest

final class DefaultCardsControllerTests: XCTestCase {
    private let mockCardsLoader = MockCardsLoader()
    
    override func setUp() {
        mockCardsLoader.loadCardsTimesCalled = 0
        mockCardsLoader.result = .success([])
        mockCardsLoader.timeout = 1.0
    }
    
    func testCardsControllerLoadCardsCompletionCalledIfCallLoadCardsOneTime() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                     cardsLoader: mockCardsLoader)
        
        let resultCards: [PaymentCard] = [.init(pan: "cardPan",
                                                cardId: "cardId",
                                                status: .active,
                                                parentPaymentId: nil,
                                                expDate: nil)]
        mockCardsLoader.result = .success(resultCards)
        
        let expectation = XCTestExpectation()
        cardsController.loadCards { result in
            switch result {
            case let .success(cards):
                XCTAssertEqual(cards, resultCards)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCardsControllerCachedCardsIfCallLoadCardsOneTime() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                     cardsLoader: mockCardsLoader)
        
        let resultCards: [PaymentCard] = [.init(pan: "cardPan",
                                                cardId: "cardId",
                                                status: .active,
                                                parentPaymentId: nil,
                                                expDate: nil)]
        mockCardsLoader.result = .success(resultCards)
        
        let expectation = XCTestExpectation()
        cardsController.loadCards { _ in
            XCTAssertEqual(cardsController.getCards(), resultCards)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCardsControllerCallsCompletionForTwoLoadCardsCallsWithResultOfSecondCallIfLoadCardsCalledSecondTimeBeforeFirstCallFinished() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                             cardsLoader: mockCardsLoader)
        
        let firstResultCards: [PaymentCard] = [.init(pan: "cardPan",
                                                     cardId: "cardId",
                                                     status: .active,
                                                     parentPaymentId: nil,
                                                     expDate: nil)]
        
        let secondResultCards: [PaymentCard] = [.init(pan: "9999",
                                                      cardId: "6666",
                                                      status: .active,
                                                      parentPaymentId: nil,
                                                      expDate: nil),
                                                .init(pan: "1111",
                                                      cardId: "2222",
                                                      status: .active,
                                                      parentPaymentId: nil,
                                                      expDate: nil)]
        
        mockCardsLoader.timeout = 0.3
        mockCardsLoader.result = .success(firstResultCards)
        
        let firstCallExpectation = XCTestExpectation()
        let secondCallExpecation = XCTestExpectation()
        
        cardsController.loadCards { result in
            switch result {
            case let .success(cards):
                XCTAssertEqual(cards, secondResultCards)
            case .failure:
                XCTFail()
            }
            firstCallExpectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.mockCardsLoader.result = .success(secondResultCards)
            cardsController.loadCards { result in
                switch result {
                case let .success(cards):
                    XCTAssertEqual(cards, secondResultCards)
                case .failure:
                    XCTFail()
                }
                secondCallExpecation.fulfill()
            }
        }
        
        wait(for: [firstCallExpectation, secondCallExpecation], timeout: 5.0)
    }

    func testCardsControllerHasCacheForTwoLoadCardsCallsWithResultOfSecondCallIfLoadCardsCalledSecondTimeBeforeFirstCallFinished() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                     cardsLoader: mockCardsLoader)
        
        let firstResultCards: [PaymentCard] = [.init(pan: "cardPan",
                                                     cardId: "cardId",
                                                     status: .active,
                                                     parentPaymentId: nil,
                                                     expDate: nil)]
        
        let secondResultCards: [PaymentCard] = [.init(pan: "9999",
                                                      cardId: "6666",
                                                      status: .active,
                                                      parentPaymentId: nil,
                                                      expDate: nil),
                                                .init(pan: "1111",
                                                      cardId: "2222",
                                                      status: .active,
                                                      parentPaymentId: nil,
                                                      expDate: nil)]
        
        mockCardsLoader.timeout = 1.0
        mockCardsLoader.result = .success(firstResultCards)
        
        let firstCallExpectation = XCTestExpectation()
        let secondCallExpecation = XCTestExpectation()
        
        cardsController.loadCards { result in
            XCTAssertEqual(cardsController.getCards(), secondResultCards)
            firstCallExpectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mockCardsLoader.result = .success(secondResultCards)
            cardsController.loadCards { result in
                XCTAssertEqual(cardsController.getCards(), secondResultCards)
                secondCallExpecation.fulfill()
            }
        }
        
        wait(for: [firstCallExpectation, secondCallExpecation], timeout: 5.0)
    }

    func testCardsControllerNotifyListenersIfLoadedCards() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                     cardsLoader: mockCardsLoader)
        
        let listener = MockCardsControllerListener()
        cardsController.addListener(listener)
        
        let resultCards: [PaymentCard] = [.init(pan: "cardPan",
                                                cardId: "cardId",
                                                status: .active,
                                                parentPaymentId: nil,
                                                expDate: nil)]
        mockCardsLoader.result = .success(resultCards)
        
        let expectation = XCTestExpectation()
        cardsController.loadCards { _ in
            XCTAssertEqual(listener.cardsControllerDidUpdateCardsTimesCalled, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCardsControllerNotifyListenerOnlyOneTimeIfLoadCardsCalledSecondTimeBeforeFirstCallFinished() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                     cardsLoader: mockCardsLoader)
        
        let listener = MockCardsControllerListener()
        cardsController.addListener(listener)
        
        mockCardsLoader.timeout = 1.0
        
        let firstCallExpectation = XCTestExpectation()
        let secondCallExpecation = XCTestExpectation()
        
        cardsController.loadCards { result in
            XCTAssertEqual(listener.cardsControllerDidUpdateCardsTimesCalled, 1)
            firstCallExpectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cardsController.loadCards { result in
                XCTAssertEqual(listener.cardsControllerDidUpdateCardsTimesCalled, 1)
                secondCallExpecation.fulfill()
            }
        }
        
        wait(for: [firstCallExpectation, secondCallExpecation], timeout: 5.0)
    }
    
    func testCardsControllerNotifyListenerOnlyTwoTimeIfLoadCardsCalledSecondTimeAfterFirstCallFinished() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                     cardsLoader: mockCardsLoader)
        
        let listener = MockCardsControllerListener()
        cardsController.addListener(listener)
        
        mockCardsLoader.timeout = 0.2
        
        let firstCallExpectation = XCTestExpectation()
        let secondCallExpecation = XCTestExpectation()
        
        cardsController.loadCards { result in
            XCTAssertEqual(listener.cardsControllerDidUpdateCardsTimesCalled, 1)
            firstCallExpectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            cardsController.loadCards { result in
                XCTAssertEqual(listener.cardsControllerDidUpdateCardsTimesCalled, 2)
                secondCallExpecation.fulfill()
            }
        }
        
        wait(for: [firstCallExpectation, secondCallExpecation], timeout: 5.0)
    }
    
    func testCardsControllerNoDeadlockIfGetCardsFromMainQueue() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                     cardsLoader: mockCardsLoader)

        let resultCards: [PaymentCard] = [.init(pan: "cardPan",
                                                cardId: "cardId",
                                                status: .active,
                                                parentPaymentId: nil,
                                                expDate: nil)]
        mockCardsLoader.result = .success(resultCards)
        mockCardsLoader.timeout = 0.1

        let expectation = XCTestExpectation()
        cardsController.loadCards { result in
            _ = cardsController.getCards()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCardsControllerGetCardsWithActiveCardsPredicate() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                     cardsLoader: mockCardsLoader)

        let activeCards: [PaymentCard] = [.init(pan: "cardPan",
                                                cardId: "cardId",
                                                status: .active,
                                                parentPaymentId: nil,
                                                expDate: nil)]
        let inactiveCards: [PaymentCard] = [.init(pan: "1111",
                                                  cardId: "2222",
                                                  status: .inactive,
                                                  parentPaymentId: nil,
                                                  expDate: nil)]
        
        let resultCards: [PaymentCard] = activeCards + inactiveCards
        mockCardsLoader.result = .success(resultCards)
        mockCardsLoader.timeout = 0.1

        let expectation = XCTestExpectation()
        cardsController.loadCards { result in
            let cards = cardsController.getCards(predicates: .activeCards)
            XCTAssertEqual(cards, activeCards)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCardsControllerGetCardsWithTwoPredicates() {
        let cardsController = DefaultCardsController(customerKey: "customerKey",
                                                     cardsLoader: mockCardsLoader)

        let activeCards: [PaymentCard] = [.init(pan: "cardPan",
                                                cardId: "cardId",
                                                status: .active,
                                                parentPaymentId: nil,
                                                expDate: nil)]
        let inactiveCards: [PaymentCard] = [.init(pan: "1111",
                                                  cardId: "2222",
                                                  status: .inactive,
                                                  parentPaymentId: nil,
                                                  expDate: nil)]
        let activeAndParentPaymentIdCards: [PaymentCard] = [.init(pan: "5555",
                                                                  cardId: "6666",
                                                                  status: .active,
                                                                  parentPaymentId: "22222",
                                                                  expDate: nil)]
        
        let resultCards: [PaymentCard] = activeCards + inactiveCards + activeAndParentPaymentIdCards
        mockCardsLoader.result = .success(resultCards)
        mockCardsLoader.timeout = 0.1

        let expectation = XCTestExpectation()
        cardsController.loadCards { result in
            let cards = cardsController.getCards(predicates: .activeCards, .parentPaymentCards)
            XCTAssertEqual(cards, activeAndParentPaymentIdCards)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
