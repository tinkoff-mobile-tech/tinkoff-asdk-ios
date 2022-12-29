//
//  YandexPayPaymentFlow.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

final class YandexPayPaymentFlow: IYandexPayPaymentFlow {
    weak var output: IYandexPayPaymentFlowOutput?
    weak var presentingViewControllerProvider: IPresentingViewControllerProvider?
    private let paymentActivityAssembly: IYandexPayPaymentActivityAssembly

    init(paymentActivityAssembly: IYandexPayPaymentActivityAssembly) {
        self.paymentActivityAssembly = paymentActivityAssembly
    }

    func start(with paymentOption: PaymentOptions, base64Token: String) {
        guard let presentingViewController = presentingViewControllerProvider?.viewControllerForPresentation() else {
            return
        }

        let paymentActivityViewController = paymentActivityAssembly.yandexPayActivity(
            paymentOptions: paymentOption,
            base64Token: base64Token,
            output: self
        )

        presentingViewController.present(paymentActivityViewController, animated: true)
    }
}

// MARK: - IYandexPayPaymentActivityOutput

extension YandexPayPaymentFlow: IYandexPayPaymentActivityOutput {
    func yandexPayPaymentActivity(completedWith result: YandexPayPaymentResult) {
        output?.yandexPayPaymentFlow(self, didCompleteWith: result)
    }
}
