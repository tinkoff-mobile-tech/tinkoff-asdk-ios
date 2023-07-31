//
//  ThreeDSWebViewHandlerBuilderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 31.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class ThreeDSWebViewHandlerBuilderMock: IThreeDSWebViewHandlerBuilder {

    // MARK: - threeDSWebViewHandler

    var threeDSWebViewHandlerCallsCount = 0
    var threeDSWebViewHandlerReturnValue: IThreeDSWebViewHandler!

    func threeDSWebViewHandler() -> IThreeDSWebViewHandler {
        threeDSWebViewHandlerCallsCount += 1
        return threeDSWebViewHandlerReturnValue
    }
}

// MARK: - Resets

extension ThreeDSWebViewHandlerBuilderMock {
    func fullReset() {
        threeDSWebViewHandlerCallsCount = 0
    }
}
