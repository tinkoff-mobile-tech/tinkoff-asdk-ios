//
//  YandexPaySDKDataMappingTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 02.06.2023.
//

@testable import TinkoffASDKYandexPay
import XCTest
import YandexPaySDK

final class YandexPaySDKDataMappingTests: BaseTestCase {

    func test_theme_light() {
        // given
        let expectedResult = YandexPayButtonTheme(appearance: .light)
        // when
        let result = YandexPayButtonTheme.from(.init(appearance: .light))
        // then
        XCTAssertEqual(result.appearance.hashValue, expectedResult.appearance.hashValue)
    }

    func test_appearance_maps_light() {
        // when
        let result = YandexPayButtonApperance.from(.light)
        // then
        XCTAssertEqual(result, .light)
    }

    func test_appearance_maps_dark() {
        // when
        let result = YandexPayButtonApperance.from(.dark)
        // then
        XCTAssertEqual(result, .dark)
    }

    func test_yandexPaySDKEnvironment_maps_sandbox() {
        // when
        let result = YandexPaySDK.YandexPaySDKEnvironment.from(.sandbox)
        // then
        XCTAssertEqual(result, .sandbox)
    }

    func test_yandexPaySDKEnvironment_maps_production() {
        // when
        let result = YandexPaySDK.YandexPaySDKEnvironment.from(.production)
        // then
        XCTAssertEqual(result, .production)
    }

    func test_yandexPaySDKLocale_maps_ru() {
        // when
        let result = YandexPaySDK.YandexPaySDKLocale.from(.ru)
        // then
        XCTAssertEqual(result, .ru)
    }

    func test_yandexPaySDKLocale_maps_en() {
        // when
        let result = YandexPaySDK.YandexPaySDKLocale.from(.en)
        // then
        XCTAssertEqual(result, .en)
    }

    func test_yandexPaySDKLocale_maps_system() {
        // when
        let result = YandexPaySDK.YandexPaySDKLocale.from(.system)
        // then
        XCTAssertEqual(result, .system)
    }
}
