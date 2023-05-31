//
//
//  TinkoffPayPaymentSheetTestsRU.swift
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

final class TinkoffPaySheetTestsRU: BaseTestCase {
    /// Dependencies
    var sheetViewController: CommonSheetViewController!
    var presenter: TinkoffPaySheetPresenter!
    var sheetContainer: PullableContainerViewController!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        sheetViewController = CommonSheetViewController(presenter: CommonSheetPresenterMock())
        sheetContainer = PullableContainerViewController(content: sheetViewController)
        sheetViewController.pullableContentDelegate = sheetContainer
    }

    override func tearDown() {
        presenter = nil
        sheetContainer = nil
        sheetViewController = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_update_timeout() {
        allureId(2500855, "Отображение \"Время оплаты истекло\" в свелой теме")
        allureId(2500857, "Отображение \"Время оплаты истекло\" в темной теме")

        // given
        let state = CommonSheetState.TinkoffPay.timedOutOnMainFormFlow

        // when
        sheetViewController.update(state: state, animatePullableContainerUpdates: false)

        // then
        assertSnapshot(
            matching: sheetContainer,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            record: false
        )

        assertSnapshot(
            matching: sheetContainer,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)),
            record: false
        )
    }

    func test_update_processing() {
        allureId(2500863, "Отображение \"Ждем оплату в приложении банка\" в свелой теме")
        allureId(2500860, "Отображение \"Ждем оплату в приложении банка\" в темной теме")

        // given
        let state = CommonSheetState.TinkoffPay.processing

        // when
        sheetViewController.update(state: state, animatePullableContainerUpdates: false)

        // then
        assertSnapshot(
            matching: sheetContainer,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            record: false
        )

        assertSnapshot(
            matching: sheetContainer,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)),
            record: false
        )
    }

    func test_update_paid() {
        allureId(2500861, "Отображение \"Оплачено\" в светлой теме")
        allureId(2500858, "Отображение \"Оплачено\" в темной теме")

        // given
        let state = CommonSheetState.TinkoffPay.paid

        // when
        sheetViewController.update(state: state, animatePullableContainerUpdates: false)

        // then
        assertSnapshot(
            matching: sheetContainer,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            record: false
        )

        assertSnapshot(
            matching: sheetContainer,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)),
            record: false
        )
    }

    func test_update_failed() {
        allureId(2500853, "Отображение \"Ошибка при оплате\" в светлой теме")
        allureId(2500856, "Отображение \"Ошибка при оплате\" в темной теме")

        // given
        let state = CommonSheetState.TinkoffPay.failedPaymentOnMainFormFlow

        // when
        sheetViewController.update(state: state, animatePullableContainerUpdates: false)

        // then
        assertSnapshot(
            matching: sheetContainer,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            record: false
        )

        assertSnapshot(
            matching: sheetContainer,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)),
            record: false
        )
    }
}
