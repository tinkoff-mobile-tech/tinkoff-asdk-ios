//
//
//  YandexPayPaymentSheetAssemblyTestsRU.swift
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
@testable import TinkoffASDKYandexPay

final class YandexPayPaymentSheetAssemblyTestsRU: BaseTestCase {

    var sheetViewController: CommonSheetViewController!
    var presenter: YandexPayPaymentSheetPresenter!
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

    func test_update_failed() {
        allureId(2358076, "Отображение Ошибки при оплате в светлой теме")
        allureId(2358082, "Отображение Ошибки при оплате в темной теме")

        // given
        let state = YandexPayPaymentSheetPresenter.SheetState.failed

        // when
        sheetViewController.update(state: state.toCommonSheetState(), animatePullableContainerUpdates: false)

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
        allureId(2358076, "Отображение контента Ошибки при оплате в светлой теме")
        allureId(2358082, "Отображение контента Ошибки при оплате в темной теме")

        // given
        let state = YandexPayPaymentSheetPresenter.SheetState.processing

        // when
        sheetViewController.update(state: state.toCommonSheetState(), animatePullableContainerUpdates: false)

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
        allureId(2358081, "Отображение Успешной оплаты в светлой теме")
        allureId(2358078, "Отображение Успешной оплаты в темной теме")

        // given
        let state = YandexPayPaymentSheetPresenter.SheetState.paid

        // when
        sheetViewController.update(state: state.toCommonSheetState(), animatePullableContainerUpdates: false)

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
