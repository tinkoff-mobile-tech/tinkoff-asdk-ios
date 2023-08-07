//
//  YandexPaySDKButtonFactoryMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKYandexPay
import YandexPaySDK

final class YandexPaySDKButtonFactoryMock: IYandexPaySDKButtonFactory {

    // MARK: - createButton

    typealias CreateButtonArguments = (configuration: YandexPaySDK.YandexPayButtonConfiguration, asyncDelegate: YandexPaySDK.YandexPayButtonAsyncDelegate)

    var createButtonCallsCount = 0
    var createButtonReceivedArguments: CreateButtonArguments?
    var createButtonReceivedInvocations: [CreateButtonArguments?] = []
    var createButtonReturnValue: YandexPaySDK.YandexPayButton!

    func createButton(configuration: YandexPaySDK.YandexPayButtonConfiguration, asyncDelegate: YandexPaySDK.YandexPayButtonAsyncDelegate) -> YandexPaySDK.YandexPayButton {
        createButtonCallsCount += 1
        let arguments = (configuration, asyncDelegate)
        createButtonReceivedArguments = arguments
        createButtonReceivedInvocations.append(arguments)
        return createButtonReturnValue
    }
}

// MARK: - Resets

extension YandexPaySDKButtonFactoryMock {
    func fullReset() {
        createButtonCallsCount = 0
        createButtonReceivedArguments = nil
        createButtonReceivedInvocations = []
    }
}
