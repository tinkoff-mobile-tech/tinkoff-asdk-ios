//
//  YandexPayPaymentSheetUIProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import UIKit
import WebKit

final class YandexPayPaymentSheetUIProvider: ThreeDSWebFlowDelegate {
    weak var view: UIViewController?
    private let webView = WKWebView()

    func hiddenWebViewToCollect3DSData() -> WKWebView {
        webView
    }

    func sourceViewControllerToPresent() -> UIViewController? {
        view
    }
}

// MARK: - Equatable

extension YandexPayPaymentSheetUIProvider {
    static func == (lhs: YandexPayPaymentSheetUIProvider, rhs: YandexPayPaymentSheetUIProvider) -> Bool {
        lhs === rhs
    }
}
