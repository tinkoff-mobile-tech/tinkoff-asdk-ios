//
//  YandexPayButtonContainerPresenter.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 04.12.2022.
//

import Foundation
import TinkoffASDKUI
import UIKit
import YandexPaySDK

protocol IYandexPayButtonContainerController {
    func requestPaymentSheet(completion: @escaping (YandexPaySDK.YPPaymentSheet?) -> Void)
    func handlePaymentResult(_ result: YandexPaySDK.YPPaymentResult)
}

final class YandexPayButtonContainerController {
    enum Error: Swift.Error {
        case inconsistentState
        case unknown
    }

    // MARK: Dependencies

    private let paymentSheetFactory: IYPPaymentSheetFactory
    private let paymentFlow: IYandexPayPaymentFlow
    private weak var delegate: YandexPayButtonContainerControllerDelegate?

    // MARK: State

    private var paymentSheet: YandexPayPaymentSheet?

    // MARK: Init

    init(
        paymentSheetFactory: IYPPaymentSheetFactory,
        paymentFlow: IYandexPayPaymentFlow,
        delegate: YandexPayButtonContainerControllerDelegate
    ) {
        self.paymentSheetFactory = paymentSheetFactory
        self.paymentFlow = paymentFlow
        self.delegate = delegate
        paymentFlow.output = self
        paymentFlow.presentingViewControllerProvider = self
    }

    // MARK: Helpers

    private func resetState() {
        paymentSheet = nil
    }
}

// MARK: - IYandexPayButtonContainerController

extension YandexPayButtonContainerController: IYandexPayButtonContainerController {
    func requestPaymentSheet(completion: @escaping (YPPaymentSheet?) -> Void) {
        delegate?.yandexPayController(self) { [weak self] paymentSheet in
            guard let self = self else { return }

            guard let paymentSheet = paymentSheet else {
                return completion(nil)
            }

            let yandexPaySDKPaymentSheet = self.paymentSheetFactory.create(with: paymentSheet)

            DispatchQueue.performOnMain {
                self.paymentSheet = paymentSheet
                completion(yandexPaySDKPaymentSheet)
            }
        }
    }

    func handlePaymentResult(_ result: YPPaymentResult) {
        defer { resetState() }

        switch result {
        case let .succeeded(paymentInfo):
            guard let paymentSheet = paymentSheet else {
                delegate?.yandexPayController(self, didCompleteWithResult: .failed(Error.inconsistentState))
                return
            }
            paymentFlow.start(with: paymentSheet.paymentOptions, base64Token: paymentInfo.paymentToken)
        case .cancelled:
            delegate?.yandexPayController(self, didCompleteWithResult: .cancelled)
        case let .failed(error):
            delegate?.yandexPayController(self, didCompleteWithResult: .failed(error))
        @unknown default:
            delegate?.yandexPayController(self, didCompleteWithResult: .failed(Error.unknown))
        }
    }
}

// MARK: - IPresentingViewControllerProvider

extension YandexPayButtonContainerController: IPresentingViewControllerProvider {
    func viewControllerForPresentation() -> UIViewController? {
        delegate?.yandexPayControllerDidRequestViewControllerForPresentation(self)
    }
}

// MARK: - IYandexPayPaymentFlowOutput

extension YandexPayButtonContainerController: IYandexPayPaymentFlowOutput {
    func yandexPayPaymentFlow(_ flow: IYandexPayPaymentFlow, didCompleteWith result: YandexPayPaymentResult) {
        delegate?.yandexPayController(self, didCompleteWithResult: result)
    }
}
