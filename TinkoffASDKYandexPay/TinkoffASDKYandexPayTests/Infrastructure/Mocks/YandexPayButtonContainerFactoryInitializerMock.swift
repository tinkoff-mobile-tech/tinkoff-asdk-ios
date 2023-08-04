//
//  YandexPayButtonContainerFactoryInitializerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
@testable import TinkoffASDKYandexPay

final class YandexPayButtonContainerFactoryInitializerMock: IYandexPayButtonContainerFactoryInitializer {

    // MARK: - initializeButtonFactory

    typealias InitializeButtonFactoryArguments = (configuration: YandexPaySDKConfiguration, method: YandexPayMethod, flowAssembly: IYandexPayPaymentFlowAssembly)

    public var initializeButtonFactoryThrowableError: Error?
    var initializeButtonFactoryCallsCount = 0
    var initializeButtonFactoryReceivedArguments: InitializeButtonFactoryArguments?
    var initializeButtonFactoryReceivedInvocations: [InitializeButtonFactoryArguments?] = []
    var initializeButtonFactoryReturnValue: IYandexPayButtonContainerFactory!

    func initializeButtonFactory(with configuration: YandexPaySDKConfiguration, method: YandexPayMethod, flowAssembly: IYandexPayPaymentFlowAssembly) throws -> IYandexPayButtonContainerFactory {
        if let error = initializeButtonFactoryThrowableError {
            throw error
        }
        initializeButtonFactoryCallsCount += 1
        let arguments = (configuration, method, flowAssembly)
        initializeButtonFactoryReceivedArguments = arguments
        initializeButtonFactoryReceivedInvocations.append(arguments)
        return initializeButtonFactoryReturnValue
    }
}

// MARK: - Resets

extension YandexPayButtonContainerFactoryInitializerMock {
    func fullReset() {
        initializeButtonFactoryThrowableError = nil
        initializeButtonFactoryCallsCount = 0
        initializeButtonFactoryReceivedArguments = nil
        initializeButtonFactoryReceivedInvocations = []
    }
}
