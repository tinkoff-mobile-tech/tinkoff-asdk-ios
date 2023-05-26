//
//
//  CardListTestsRU.swift
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

import SnapshotTesting
import TinkoffASDKCore
import XCTest

@testable import ASDKSample
@testable import TestsSharedInfrastructure
@testable import TinkoffASDKUI
@testable import TinkoffASDKYandexPay

final class CardListTestsRU: BaseTestCase {

    var sut: UIViewController!

    // Mocks

    var cardsControllerAssemblyMock: CardsControllerAssemblyMock!
    var cardsControllerMock: CardsControllerMock!

    // MARK: - Setup

    override func setUp() {
        AppSetting.shared.setAnimationsEnabled = false

        cardsControllerAssemblyMock = CardsControllerAssemblyMock()
        cardsControllerMock = CardsControllerMock()
        cardsControllerAssemblyMock.cardsControllerReturnValue = cardsControllerMock
        let assembly = CardListAssembly(
            paymentControllerAssembly: PaymentControllerAssemblyMock(),
            cardsControllerAssembly: cardsControllerAssemblyMock,
            addNewCardAssembly: AddNewCardAssemblyMock()
        )
        let cardListViewController = assembly.cardsPresentingNavigationController(
            customerKey: "customerKey",
            cardScannerDelegate: nil
        )
        sut = cardListViewController
        super.setUp()
    }

    override func tearDown() {
        cardsControllerAssemblyMock = nil
        cardsControllerMock = nil
        sut = nil
        AppSetting.shared.setAnimationsEnabled = true
        super.tearDown()
    }

    // MARK: - Tests

    func test_cardList_screen() {
        allureId(2397541, "Отображение в светлой теме")
        allureId(2397542, "Отображение в темной теме")

        // given
        cardsControllerMock.getActiveCardsStub = { $0(.success(.fake())) }
        sut.view.setNeedsLayout()
        sut.view.layoutIfNeeded()

        // when
        sut.viewDidLoad()
        quickWait(expectation(description: #function))

        // then
        assertSnapshot(
            matching: sut.view,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            record: false
        )

        assertSnapshot(
            matching: sut.view,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            record: false
        )
    }
}

extension XCTestCase {

    /// Ждем 1 милисекунду - нужна в дополнении к AppSetting.shared.setAnimationsEnabled = false
    /// Так как не успевает отработать completion анимации (даже если она выключена)
    func quickWait(_ expectation: @autoclosure () -> XCTestExpectation) {
        let expectation = expectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.002)
    }
}
