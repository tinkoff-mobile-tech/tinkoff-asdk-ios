//
//  YandexPayButtonContainerFactoryTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 05.06.2023.
//

import TinkoffASDKCore
import TinkoffASDKUI
@testable import TinkoffASDKYandexPay
import XCTest
import YandexPaySDK

final class YandexPayButtonContainerFactoryTests: BaseTestCase {

    var sut: YandexPayButtonContainerFactory!

    // Mocks
    var sdkButtonFactoryMock: YandexPaySDKButtonFactoryMock!
    var yandexPayPaymentFlowAssemblyMock: YandexPayPaymentFlowAssemblyMock!
    var method: YandexPayMethod!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        sdkButtonFactoryMock = YandexPaySDKButtonFactoryMock()
        yandexPayPaymentFlowAssemblyMock = YandexPayPaymentFlowAssemblyMock()
        method = .fake()
        sdkButtonFactoryMock.createButtonReturnValue = YandexPayButtonMock()

        sut = YandexPayButtonContainerFactory(
            sdkButtonFactory: sdkButtonFactoryMock,
            yandexPayPaymentFlowAssembly: yandexPayPaymentFlowAssemblyMock,
            method: method
        )
    }

    override func tearDown() {
        sdkButtonFactoryMock = nil
        yandexPayPaymentFlowAssemblyMock = nil
        method = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_createButtonContainer() {
        // given
        let delegateMock = YandexPayButtonContainerDelegateMock()
        let configuration = YandexPayButtonContainerConfiguration(theme: .init(appearance: .dark))

        // when
        let createdButtonContainer = sut.createButtonContainer(
            with: configuration,
            delegate: delegateMock
        )
        // then
        XCTAssertEqual(
            createdButtonContainer.theme.appearance.hashValue,
            configuration.theme.appearance.hashValue
        )
        XCTAssertEqual(sdkButtonFactoryMock.createButtonCallsCount, 1)
    }
}
