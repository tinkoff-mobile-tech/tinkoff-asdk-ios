//
//  YandexPayPaymentSheetUIProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import UIKit
import WebKit

final class YandexPayPaymentSheetUIProvider: PaymentControllerUIProvider {
    weak var view: UIViewController?
    private let webView = WKWebView()

    func hiddenWebViewToCollect3DSData() -> WKWebView {
        webView
    }

    func sourceViewControllerToPresent() -> UIViewController? {
        view
    }
}
