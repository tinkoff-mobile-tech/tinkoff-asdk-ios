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

    typealias CreateButtonArguments = (configuration: YandexPayButtonConfiguration, asyncDelegate: YandexPayButtonAsyncDelegate)

    var createButtonCallsCount = 0
    var createButtonReceivedArguments: CreateButtonArguments?
    var createButtonReceivedInvocations: [CreateButtonArguments] = []
    var createButtonReturnValue: YandexPayButton!

    func createButton(configuration: YandexPayButtonConfiguration, asyncDelegate: YandexPayButtonAsyncDelegate) -> YandexPayButton {
        createButtonCallsCount += 1
        let arguments = (configuration, asyncDelegate)
        createButtonReceivedArguments = arguments
        createButtonReceivedInvocations.append(arguments)
        return createButtonReturnValue
    }
}
