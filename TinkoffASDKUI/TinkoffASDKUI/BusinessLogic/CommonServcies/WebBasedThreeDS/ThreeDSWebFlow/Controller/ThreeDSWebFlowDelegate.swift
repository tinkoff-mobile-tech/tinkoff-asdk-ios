//
//  ThreeDSWebFlowDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import UIKit
import WebKit

/// Объект, предоставляющий UI-компоненты для прохождения `3DS Web Based Flow`
public protocol ThreeDSWebFlowDelegate: AnyObject {
    /// webView, в котором выполнится запрос для прохождения 3DSChecking
    func hiddenWebViewToCollect3DSData() -> WKWebView
    /// viewController для модального показа экрана с webView, необходимость в котором может возникнуть в процессе оплаты
    func sourceViewControllerToPresent() -> UIViewController?
}
