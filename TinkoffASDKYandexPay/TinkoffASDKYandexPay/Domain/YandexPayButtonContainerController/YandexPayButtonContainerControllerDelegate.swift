//
//  YandexPayButtonContainerControllerDelegate.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 19.12.2022.
//

import TinkoffASDKUI
import UIKit

protocol YandexPayButtonContainerControllerDelegate: AnyObject {
    func yandexPayControllerDidRequestViewControllerForPresentation(
        _ controller: IYandexPayButtonContainerController
    ) -> UIViewController?

    func yandexPayController(
        _ controller: IYandexPayButtonContainerController,
        didRequestPaymentSheet completion: @escaping (YandexPayPaymentSheet?) -> Void
    )

    func yandexPayController(
        _ controller: YandexPayButtonContainerController,
        didCompleteWithResult result: YandexPayPaymentResult
    )
}
