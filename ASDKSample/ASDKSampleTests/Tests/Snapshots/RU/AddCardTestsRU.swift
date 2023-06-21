//
//
//  AddCardTestsRU.swift
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

@testable import TestsSharedInfrastructure
@testable import TinkoffASDKUI

final class AddCardTestsRU: BaseTestCase {

    var sut: AddNewCardViewController!

    // MARK: - Setup

    override func setUp() {
        let cardsControllerAssemblyMock = CardsControllerAssemblyMock()
        cardsControllerAssemblyMock.cardsControllerReturnValue = CardsControllerMock()
        sut = AddNewCardAssembly(cardsControllerAssembly: cardsControllerAssemblyMock)
            .addNewCardView(
                customerKey: "",
                output: nil,
                cardScannerDelegate: CardScannerDelegateMock()
            )

        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_appearance_on_load() {
        allureId(2397543, "Отображение в светлой теме")
        allureId(2397544, "Отображение в темной теме")

        // then
        assertSnapshot(
            matching: sut,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            record: false
        )
        assertSnapshot(
            matching: sut,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)),
            record: false
        )
    }
}
