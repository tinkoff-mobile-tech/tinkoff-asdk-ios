//
//  ThreeDSWebFlowDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

@testable import TinkoffASDKUI
import UIKit
import WebKit

final class ThreeDSWebFlowDelegateMock: ThreeDSWebFlowDelegate {

    // MARK: - hiddenWebViewToCollect3DSData

    var hiddenWebViewToCollect3DSDataCallsCount = 0
    var hiddenWebViewToCollect3DSDataReturnValue: WKWebView = .init(frame: .zero)

    func hiddenWebViewToCollect3DSData() -> WKWebView {
        hiddenWebViewToCollect3DSDataCallsCount += 1
        return hiddenWebViewToCollect3DSDataReturnValue
    }

    // MARK: - sourceViewControllerToPresent

    var sourceViewControllerToPresentCallsCount = 0
    var sourceViewControllerToPresentReturnValue: UIViewController?

    func sourceViewControllerToPresent() -> UIViewController? {
        sourceViewControllerToPresentCallsCount += 1
        return sourceViewControllerToPresentReturnValue
    }
}

// MARK: - Resets

extension ThreeDSWebFlowDelegateMock {
    func fullReset() {
        hiddenWebViewToCollect3DSDataCallsCount = 0

        sourceViewControllerToPresentCallsCount = 0
    }
}

// MARK: - Equatable

extension ThreeDSWebFlowDelegateMock {
    static func == (lhs: ThreeDSWebFlowDelegateMock, rhs: ThreeDSWebFlowDelegateMock) -> Bool {
        lhs === rhs
    }
}
