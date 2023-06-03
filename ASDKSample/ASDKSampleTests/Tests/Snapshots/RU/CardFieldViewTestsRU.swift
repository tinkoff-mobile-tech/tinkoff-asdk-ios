//
//
//  CardFieldViewTestsRU.swift
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

final class CardFieldViewTestsRU: BaseTestCase {

    var view: CardFieldView!
    var presenter: ICardFieldViewOutput!

    // MARK: - Setup

    override func setUp() {
        let psResolver = PaymentSystemResolver()
        let cardFieldPresenter = CardFieldPresenterAssembly(
            validator: CardRequisitesValidator(),
            paymentSystemResolver: psResolver,
            bankResolver: BankResolver(),
            inputMaskResolver: CardRequisitesMasksResolver(paymentSystemResolver: psResolver)
        )
        .build(isScanButtonNeeded: true)

        view = CardFieldView(frame: CGRect(x: 0, y: 0, width: 350, height: 200))
        view.presenter = cardFieldPresenter
        presenter = cardFieldPresenter
        super.setUp()
    }

    override func tearDown() {
        view = nil
        presenter = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_cvc_field_has_hint() {
        allureId(2570088, "Отображение хинта в поле ввода CVC")

        // when
        presenter.activate(textFieldType: .cvc)

        // then
        assertSnapshot(
            matching: view,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            record: false
        )
    }

    func test_expiration_field_has_hint() {
        allureId(2564264, "Отображение хинта в поле ввода Срок")

        // when
        presenter.activate(textFieldType: .expiration)

        // then
        assertSnapshot(
            matching: view,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            record: false
        )
    }
}
