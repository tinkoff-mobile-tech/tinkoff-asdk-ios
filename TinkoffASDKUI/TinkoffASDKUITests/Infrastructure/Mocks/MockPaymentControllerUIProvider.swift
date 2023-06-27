//
//  MockPaymentControllerUIProvider.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 21.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI
import class UIKit.UIViewController
import WebKit

final class MockPaymentControllerUIProvider: ThreeDSWebFlowDelegate {

    // MARK: - hiddenWebViewToCollect3DSData

    var hiddenWebViewToCollect3DSDataCallCounter = 0
    var hiddenWebViewToCollect3DSDataReturnStub: () -> WKWebView = { WKWebView() }

    func hiddenWebViewToCollect3DSData() -> WKWebView {
        hiddenWebViewToCollect3DSDataCallCounter += 1
        return hiddenWebViewToCollect3DSDataReturnStub()
    }

    // MARK: - sourceViewControllerToPresent

    var sourceViewControllerToPresentCallCounter = 0
    var sourceViewControllerToPresentReturnStub: () -> UIViewController? = { UIViewController() }

    func sourceViewControllerToPresent() -> UIViewController? {
        sourceViewControllerToPresentCallCounter += 1
        return sourceViewControllerToPresentReturnStub()
    }
}

// MARK: - Equatable

extension MockPaymentControllerUIProvider {
    static func == (lhs: MockPaymentControllerUIProvider, rhs: MockPaymentControllerUIProvider) -> Bool {
        lhs === rhs
    }
}
