//
//  YandexPayPaymentSheetAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import Foundation
import UIKit
import WebKit

final class YandexPayPaymentSheetAssembly: IYandexPayPaymentSheetAssembly {
    private let paymentControllerAssembly: IPaymentControllerAssembly

    init(paymentControllerAssembly: IPaymentControllerAssembly) {
        self.paymentControllerAssembly = paymentControllerAssembly
    }

    func yandexPayActivity(
        paymentFlow: PaymentFlow,
        base64Token: String,
        output: IYandexPayPaymentSheetOutput
    ) -> UIViewController {
        let paymentControllerUIProvider = YandexPayPaymentSheetUIProvider()
        let paymentController = paymentControllerAssembly.paymentController()

        let presenter = YandexPayPaymentSheetPresenter(
            paymentController: paymentController,
            paymentControllerUIProvider: paymentControllerUIProvider,
            paymentFlow: paymentFlow,
            base64Token: base64Token,
            output: output
        )

        let view = CommonSheetViewController(presenter: presenter)

        presenter.view = view
        paymentControllerUIProvider.view = view
        paymentController.delegate = presenter
        paymentController.uiProvider = paymentControllerUIProvider

        return PullableContainerViewController(content: view)
    }
}
