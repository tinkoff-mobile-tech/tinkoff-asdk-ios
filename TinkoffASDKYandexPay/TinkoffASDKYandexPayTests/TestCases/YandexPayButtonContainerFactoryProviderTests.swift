//
//  YandexPayButtonContainerFactoryProviderTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 19.04.2023.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
@testable import TinkoffASDKYandexPay

import XCTest

final class YandexPayButtonContainerFactoryProviderTests: BaseTestCase {

    var sut: YandexPayButtonContainerFactoryProvider!

    // Mocks

    var paymentFlowAssemblyMock: YandexPayPaymentFlowAssemblyMock!
    var methodProviderMock: YandexPayMethodProviderMock!
    var buttonContainerFactoryInitializerMock: YandexPayButtonContainerFactoryInitializerMock!
    var buttonContainerFactoryMock: YandexPayButtonContainerFactoryMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        paymentFlowAssemblyMock = YandexPayPaymentFlowAssemblyMock()
        methodProviderMock = YandexPayMethodProviderMock()
        buttonContainerFactoryInitializerMock = YandexPayButtonContainerFactoryInitializerMock()
        buttonContainerFactoryMock = YandexPayButtonContainerFactoryMock()

        sut = YandexPayButtonContainerFactoryProvider(
            flowAssembly: paymentFlowAssemblyMock,
            methodProvider: methodProviderMock
        )
    }

    override func tearDown() {
        paymentFlowAssemblyMock = nil
        methodProviderMock = nil
        buttonContainerFactoryInitializerMock = nil
        buttonContainerFactoryMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_yandexPayButtonContainerFactory_success() throws {
        allureId(2358072) // Инициализирован SDK YP

        // given
        var buttonContainer: IYandexPayButtonContainerFactory?
        buttonContainerFactoryInitializerMock.initializeButtonFactoryReturnValue = buttonContainerFactoryMock
        methodProviderMock.provideMethodCompletionClosureInput = .success(YandexPayMethod.fake())

        // when
        sut.yandexPayButtonContainerFactory(
            with: .sandboxRu,
            initializer: buttonContainerFactoryInitializerMock,
            completion: { result in
                buttonContainer = try? result.get()
            }
        )

        // then
        let container = try XCTUnwrap(buttonContainer)
        XCTAssert(container === buttonContainerFactoryMock)
    }

    func test_yandexPayButtonContainerFactory_failure_on_initialize() {
        allureId(2358074, "Не отображаем кнопку YP, если не смогли проинициализировать Yandex SDK")

        // given
        buttonContainerFactoryInitializerMock.initializeButtonFactoryThrowableError = TestsError.basic
        methodProviderMock.provideMethodCompletionClosureInput = .success(YandexPayMethod.fake())

        var receivedError: Error?

        // when
        sut.yandexPayButtonContainerFactory(
            with: .sandboxRu,
            initializer: buttonContainerFactoryInitializerMock,
            completion: { result in
                switch result {
                case let .failure(error):
                    receivedError = error
                default: break
                }
            }
        )

        // then
        XCTAssertEqual(TestsError.basic, receivedError as? TestsError)
    }

    func test_yandexPayButtonContainerFactory_failure() throws {
        allureId(2358072) // Инициализирован SDK YP

        // given
        var receivedError: Error?
        buttonContainerFactoryInitializerMock.initializeButtonFactoryReturnValue = buttonContainerFactoryMock
        methodProviderMock.provideMethodCompletionClosureInput = .failure(TestsError.basic)

        // when
        sut.yandexPayButtonContainerFactory(
            with: .sandboxRu,
            initializer: buttonContainerFactoryInitializerMock,
            completion: { result in
                switch result {
                case let .failure(error):
                    receivedError = error
                default:
                    break
                }
            }
        )

        // then
        let error = try XCTUnwrap(receivedError as? TestsError)
        XCTAssertEqual(error, .basic)
    }
}

private extension YandexPaySDKConfiguration {
    static let sandboxRu = YandexPaySDKConfiguration(environment: .sandbox, locale: .ru)
}
