//
//  ThreeDSWebFlowControllerAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

final class ThreeDSWebFlowControllerAssembly: IThreeDSWebFlowControllerAssembly {
    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let threeDSWebViewAssembly: IThreeDSWebViewAssembly

    // MARK: Init

    init(coreSDK: AcquiringSdk, threeDSWebViewAssembly: IThreeDSWebViewAssembly) {
        self.coreSDK = coreSDK
        self.threeDSWebViewAssembly = threeDSWebViewAssembly
    }

    // MARK: IThreeDSWebFlowControllerAssembly

    func threeDSWebFlowController() -> IThreeDSWebFlowController {
        ThreeDSWebFlowController(
            threeDSService: coreSDK,
            threeDSWebViewAssembly: threeDSWebViewAssembly
        )
    }
}
