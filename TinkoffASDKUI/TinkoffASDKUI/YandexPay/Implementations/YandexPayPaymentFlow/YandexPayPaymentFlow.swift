//
//  YandexPayPaymentFlow.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

final class YandexPayPaymentFlow: IYandexPayPaymentFlow {
    private let yandexPayPaymentSheetAssembly: IYandexPayPaymentSheetAssembly
    private weak var delegate: YandexPayPaymentFlowDelegate?

    init(yandexPayPaymentSheetAssembly: IYandexPayPaymentSheetAssembly, delegate: YandexPayPaymentFlowDelegate) {
        self.yandexPayPaymentSheetAssembly = yandexPayPaymentSheetAssembly
        self.delegate = delegate
    }

    func start(with paymentFlow: PaymentFlow, base64Token: String) {
        guard let presentingViewController = delegate?.yandexPayPaymentFlowDidRequestViewControllerForPresentation(self) else {
            return
        }

        let paymentActivityViewController = yandexPayPaymentSheetAssembly.yandexPayPaymentSheet(
            paymentFlow: paymentFlow,
            base64Token: base64Token,
            output: self
        )

        presentingViewController.present(paymentActivityViewController, animated: true)
    }
}

// MARK: - IYandexPayPaymentSheetOutput

extension YandexPayPaymentFlow: IYandexPayPaymentSheetOutput {
    func yandexPayPaymentActivity(completedWith result: PaymentResult) {
        delegate?.yandexPayPaymentFlow(self, didCompleteWith: result)
    }
}
