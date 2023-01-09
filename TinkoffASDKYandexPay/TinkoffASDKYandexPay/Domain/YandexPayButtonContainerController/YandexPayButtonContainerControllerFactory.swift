//
//  YandexPayButtonContainerControllerFactory.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 09.12.2022.
//

import Foundation
import TinkoffASDKCore
import TinkoffASDKUI

protocol IYandexPayButtonContainerControllerFactory {
    func create(with delegate: YandexPayButtonContainerControllerDelegate) -> IYandexPayButtonContainerController
}

final class YandexPayButtonContainerControllerFactory: IYandexPayButtonContainerControllerFactory {
    private let paymentSheetFactory: IYPPaymentSheetFactory
    private let paymentFlowAssembly: IYandexPayPaymentFlowAssembly

    init(
        paymentSheetFactory: IYPPaymentSheetFactory,
        paymentFlowAssembly: IYandexPayPaymentFlowAssembly
    ) {
        self.paymentSheetFactory = paymentSheetFactory
        self.paymentFlowAssembly = paymentFlowAssembly
    }

    func create(with delegate: YandexPayButtonContainerControllerDelegate) -> IYandexPayButtonContainerController {
        YandexPayButtonContainerController(
            paymentSheetFactory: paymentSheetFactory,
            paymentFlow: paymentFlowAssembly.yandexPayPaymentFlow(),
            delegate: delegate
        )
    }
}
