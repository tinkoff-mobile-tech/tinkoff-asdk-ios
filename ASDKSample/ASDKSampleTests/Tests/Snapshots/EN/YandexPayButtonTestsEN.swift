//
//
//  YandexPayButtonTestsEN.swift
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
import TinkoffASDKUI
import XCTest

@testable import ASDKSample
@testable import TestsSharedInfrastructure
@testable import TinkoffASDKYandexPay

final class YandexPayButtonTestsEN: BaseTestCase {

    // MARK: - Tests

    func test_snapshot_yandexPayButton() throws {
        allureId(2406334, "Отображение кнопки YP в en локализации")
        allureId(2406336, "Отображение кнопки YP в максимальных размерах")
        allureId(2406335, "Отображение кнопки YP в минимальных размерах")
        allureId(2406332, "Отображение кнопки YP в светлой теме")
        allureId(2406331, "Отображение кнопки YP в темной теме")

        // when
        let result = try XCTUnwrap(try YandexPayHelper.getYandexPayButtons(locale: .en))
        // then
        assertSnapshot(matching: result.full, as: .image(traits: .init(userInterfaceStyle: .dark)), record: false)
        assertSnapshot(matching: result.compact, as: .image(traits: .init(userInterfaceStyle: .dark)), record: false)
        assertSnapshot(matching: result.full, as: .image(traits: .init(userInterfaceStyle: .light)), record: false)
        assertSnapshot(matching: result.compact, as: .image(traits: .init(userInterfaceStyle: .light)), record: false)
    }
}
