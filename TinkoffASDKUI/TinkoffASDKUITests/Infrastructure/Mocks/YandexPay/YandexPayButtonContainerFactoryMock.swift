//
//  YandexPayButtonContainerFactoryMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

final class YandexPayButtonContainerFactoryMock: IYandexPayButtonContainerFactory {
    // MARK: - createButtonContainer

    typealias CreateButtonContainerArguments = (configuration: YandexPayButtonContainerConfiguration, delegate: IYandexPayButtonContainerDelegate)

    var createButtonContainerCallsCount = 0
    var createButtonContainerReceivedArguments: CreateButtonContainerArguments?
    var createButtonContainerReceivedInvocations: [CreateButtonContainerArguments] = []
    var createButtonContainerReturnValue: IYandexPayButtonContainer!

    func createButtonContainer(with configuration: YandexPayButtonContainerConfiguration, delegate: IYandexPayButtonContainerDelegate) -> IYandexPayButtonContainer {
        createButtonContainerCallsCount += 1
        let arguments = (configuration, delegate)
        createButtonContainerReceivedArguments = arguments
        createButtonContainerReceivedInvocations.append(arguments)
        return createButtonContainerReturnValue
    }
}
