//
//  YandexPayPaymentActivityAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import Foundation
import UIKit
import WebKit

final class YandexPayPaymentActivityAssembly: IYandexPayPaymentActivityAssembly {
    private let paymentControllerAssembly: IPaymentControllerAssembly

    init(paymentControllerAssembly: IPaymentControllerAssembly) {
        self.paymentControllerAssembly = paymentControllerAssembly
    }

    func yandexPayActivity(
        paymentOptions: PaymentOptions,
        base64Token: String,
        output: IYandexPayPaymentActivityOutput
    ) -> UIViewController {
        let paymentControllerUIProvider = YandexPayPaymentActivityUIProvider()
        let paymentController = paymentControllerAssembly.paymentController()

        let presenter = YandexPayPaymentActivityPresenter(
            paymentController: paymentController,
            paymentControllerUIProvider: paymentControllerUIProvider,
            paymentOptions: paymentOptions,
            base64Token: base64Token,
            output: output
        )

        let view = PaymentActivityViewController(presenter: presenter)

        presenter.view = view
        paymentControllerUIProvider.view = view
        paymentController.delegate = presenter
        paymentController.uiProvider = paymentControllerUIProvider

        return PullableContainerViewController(content: view)
    }
}
