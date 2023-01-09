//
//  YandexPayButtonContainerFactory.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 30.11.2022.
//

import Foundation
import TinkoffASDKCore
import TinkoffASDKUI
import YandexPaySDK

final class YandexPayButtonContainerFactory: IYandexPayButtonContainerFactory {
    private let sdkButtonFactory: IYandexPaySDKButtonFactory
    private let controllerFactory: IYandexPayButtonContainerControllerFactory

    init(
        sdkButtonFactory: IYandexPaySDKButtonFactory,
        controllerFactory: IYandexPayButtonContainerControllerFactory
    ) {
        self.sdkButtonFactory = sdkButtonFactory
        self.controllerFactory = controllerFactory
    }

    func createButtonContainer(
        with configuration: YandexPayButtonContainerConfiguration,
        delegate: YandexPayButtonContainerDelegate
    ) -> IYandexPayButtonContainer {
        YandexPayButtonContainer(
            configuration: configuration,
            sdkButtonFactory: sdkButtonFactory,
            controllerFactory: controllerFactory,
            delegate: delegate
        )
    }
}
