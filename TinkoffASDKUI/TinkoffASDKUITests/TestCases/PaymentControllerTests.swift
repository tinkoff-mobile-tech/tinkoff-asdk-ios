//
//  PaymentControllerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 16.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class PaymentControllerTests: XCTestCase {

    // MARK: - func performInitPayment()

    func test_performInitPayment() throws {
        // given
        let dependecies = try Self.makeDependencies()
        let paymentController = dependecies.paymentController
        let paymentFactoryMock = dependecies.paymentFactoryMock
        let paymentOptions = dependecies.paymentOptions
        let paymentProcessDelegateMock = dependecies.paymentProcessDelegateMock

        let mockPaymentProccess = MockPaymentProcess(
            paymentFlow: .full(paymentOptions: dependecies.paymentOptions),
            paymentSource: dependecies.paymentSource
        )

        paymentFactoryMock.createPaymentStubReturn = mockPaymentProccess

        // when
        paymentController.performInitPayment(
            paymentOptions: paymentOptions,
            paymentSource: dependecies.paymentSource
        )

        // then
        XCTAssertTrue(paymentFactoryMock.createPaymentCallCounter == 1)
        XCTAssertNotNil(paymentFactoryMock.createPaymentPassedArguments, "Should pass arguments")

        let passedArguments = paymentFactoryMock.createPaymentPassedArguments!

        if case let .full(options) = passedArguments.paymentFlow {
            XCTAssertTrue(options == paymentOptions)
        } else {
            XCTFail("Should be full payment mode")
        }

        XCTAssertTrue(passedArguments.paymentDelegate === paymentProcessDelegateMock)
        XCTAssertTrue(mockPaymentProccess.startCallCounter == 1)
        XCTAssertTrue(dependecies.tdsHandlerMock.handleCallCounter == 0)
    }

    // MARK: - func performFinishPayment()

    func test_performFinishPayment() throws {
        // given
        let dependecies = try Self.makeDependencies()

        let paymentId = "324234"
        let customerOptions = CustomerOptions()
        let paymentSource = UIASDKTestsAssembly.makePaymentSourceData_cardNumber()

        let mockPaymentProccess = MockPaymentProcess(
            paymentFlow: .full(paymentOptions: dependecies.paymentOptions),
            paymentSource: dependecies.paymentSource
        )

        dependecies.paymentFactoryMock.createPaymentStubReturn = mockPaymentProccess

        // when

        dependecies.paymentController.performFinishPayment(
            paymentId: paymentId,
            paymentSource: paymentSource,
            customerOptions: customerOptions
        )

        // then
        XCTAssertEqual(
            dependecies.paymentFactoryMock.createPaymentCallCounter,
            1
        )
        XCTAssertEqual(mockPaymentProccess.startCallCounter, 1)
    }
}

extension PaymentControllerTests {

    struct Dependencies {
        // Mocks
        let paymentFactoryMock: MockPaymentFactory
        let paymentProcessDelegateMock: MockPaymentProcessDelegate
        let tdsControllerMock: MockTDSController
        let tdsHandlerMock: MockThreeDSWebViewHandler
        let paymentControllerUIProviderMock: MockPaymentControllerUIProvider
        let threeDSServiceMock: MockAcquiringThreeDsService
        let paymentControllerDelegateMock: MockPaymentControllerDelegate

        // Data
        let paymentOptions: PaymentOptions
        let paymentSource: PaymentSourceData

        // Other
        let configuration: AcquiringSdkConfiguration
        let deviceInfoProvider: ThreeDSDeviceInfoProvider
        let uiSDK: AcquiringUISDK
        let coreSDK: AcquiringSdk

        // Controllers
        let paymentController: PaymentController
    }

    static func makeDependencies() throws -> Dependencies {
        let configuration = AcquiringSdkConfiguration(
            credential: AcquiringSdkCredential(
                terminalKey: UnitTestStageTestData.terminalKey,
                publicKey: UnitTestStageTestData.testPublicKey
            ),
            tinkoffPayStatusCacheLifeTime: 300
        )

        let paymentFactoryMock = MockPaymentFactory()
        let paymentProcessDelegateMock = MockPaymentProcessDelegate()
        let tdsControllerMock = MockTDSController()
        let tdsHandlerMock = MockThreeDSWebViewHandler()
        let paymentControllerUIProviderMock = MockPaymentControllerUIProvider()
        let threeDSServiceMock = MockAcquiringThreeDsService()
        let paymentControllerDelegateMock = MockPaymentControllerDelegate()

        let deviceInfoProvider = ThreeDSDeviceInfoProvider(
            screenSize: UIScreen.main.bounds.size,
            languageProvider: LanguageProvider(language: .ru),
            urlBuilder: ThreeDSURLBuilder(
                baseURLProvider: URLProvider(host: "no")!
            )
        )

        let uiSDK = try AcquiringUISDK(configuration: configuration)
        let coreSDK = uiSDK.acquiringSdk

        let paymentController = PaymentController(
            threeDsService: threeDSServiceMock,
            paymentFactory: paymentFactoryMock,
            threeDSHandler: tdsHandlerMock,
            threeDSDeviceParamsProvider: deviceInfoProvider,
            tdsController: tdsControllerMock,
            acquiringUISDK: uiSDK,
            paymentDelegate: paymentProcessDelegateMock
        )

        paymentController.uiProvider = paymentControllerUIProviderMock
        paymentController.delegate = paymentControllerDelegateMock

        return Dependencies(
            paymentFactoryMock: paymentFactoryMock,
            paymentProcessDelegateMock: paymentProcessDelegateMock,
            tdsControllerMock: tdsControllerMock,
            tdsHandlerMock: tdsHandlerMock,
            paymentControllerUIProviderMock: paymentControllerUIProviderMock,
            threeDSServiceMock: threeDSServiceMock,
            paymentControllerDelegateMock: paymentControllerDelegateMock,
            paymentOptions: UIASDKTestsAssembly.makePaymentOptions(),
            paymentSource: UIASDKTestsAssembly.makePaymentSourceData_cardNumber(),
            configuration: configuration,
            deviceInfoProvider: deviceInfoProvider,
            uiSDK: uiSDK,
            coreSDK: coreSDK,
            paymentController: paymentController
        )
    }
}
