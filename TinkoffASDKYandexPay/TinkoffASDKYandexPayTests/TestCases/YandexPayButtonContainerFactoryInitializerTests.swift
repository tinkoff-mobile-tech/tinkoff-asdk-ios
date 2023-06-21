//
//  YandexPayButtonContainerFactoryInitializerTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 23.05.2023.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
@testable import TinkoffASDKYandexPay
import XCTest
import YandexPaySDK

final class YandexPayButtonContainerFactoryInitializerTests: BaseTestCase {

    var sut: YandexPayButtonContainerFactoryInitializer!

    // Mocks
    var yandexPaySDKFacadeMock: YandexPaySDKFacadeMock!
    var yandexPayPaymentFlowAssemblyMock: YandexPayPaymentFlowAssemblyMock!

    override func setUp() {
        yandexPaySDKFacadeMock = YandexPaySDKFacadeMock()
        yandexPayPaymentFlowAssemblyMock = YandexPayPaymentFlowAssemblyMock()
        sut = YandexPayButtonContainerFactoryInitializer(yandexPaySDK: yandexPaySDKFacadeMock)
        super.setUp()
    }

    override func tearDown() {
        yandexPaySDKFacadeMock = nil
        yandexPayPaymentFlowAssemblyMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_initializeButtonFactory() throws {
        allureId(2358057, "Передача параметров для инициализации SDK YandexPay")

        // given
        let configuration = YandexPaySDKConfiguration(
            environment: .sandbox,
            locale: .ru
        )

        let ypMethod = YandexPayMethod.fake()
        yandexPaySDKFacadeMock.underlyingIsInitialized = false

        // when
        let buttonContainerFactory = try? sut.initializeButtonFactory(
            with: configuration,
            method: ypMethod,
            flowAssembly: yandexPayPaymentFlowAssemblyMock
        )

        // then
        XCTAssertNotNil(buttonContainerFactory)
        XCTAssertEqual(yandexPaySDKFacadeMock.initializeCallsCount, 1)
        let initializeArgument = yandexPaySDKFacadeMock.initializeReceivedArguments
        XCTAssertEqual(initializeArgument?.locale, .ru)
        XCTAssertEqual(initializeArgument?.environment, .sandbox)
        XCTAssertEqual(initializeArgument?.merchant.id, ypMethod.showcaseId)
        XCTAssertEqual(initializeArgument?.merchant.name, ypMethod.merchantName)
        XCTAssertEqual(initializeArgument?.merchant.url, ypMethod.merchantOrigin)
        XCTAssertEqual(initializeArgument?.merchant.origin, ypMethod.merchantOrigin)
    }
}
