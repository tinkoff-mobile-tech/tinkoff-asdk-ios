//
//  YandexPayPaymentFlow.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

final class YandexPayPaymentFlow: IYandexPayPaymentFlow {
    private let paymentActivityAssembly: IYandexPayPaymentSheetAssembly
    private weak var delegate: YandexPayPaymentFlowDelegate?

    init(paymentActivityAssembly: IYandexPayPaymentSheetAssembly, delegate: YandexPayPaymentFlowDelegate) {
        self.paymentActivityAssembly = paymentActivityAssembly
        self.delegate = delegate
    }

    func start(with paymentFlow: PaymentFlow, base64Token: String) {
        guard let presentingViewController = delegate?.yandexPayPaymentFlowDidRequestViewControllerForPresentation(self) else {
            return
        }

        let paymentActivityViewController = paymentActivityAssembly.yandexPayActivity(
            paymentFlow: paymentFlow,
            base64Token: base64Token,
            output: self
        )

        presentingViewController.present(paymentActivityViewController, animated: true)
    }
}

// MARK: - IYandexPayPaymentSheetOutput

extension YandexPayPaymentFlow: IYandexPayPaymentSheetOutput {
    func yandexPayPaymentActivity(completedWith result: YandexPayPaymentResult) {
        delegate?.yandexPayPaymentFlow(self, didCompleteWith: result)
    }
}
