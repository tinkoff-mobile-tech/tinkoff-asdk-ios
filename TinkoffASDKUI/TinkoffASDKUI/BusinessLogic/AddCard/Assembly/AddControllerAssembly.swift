//
//  AddControllerAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

final class AddCardControllerAssembly: IAddCardControllerAssembly {
    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let webFlowControllerAssembly: IThreeDSWebFlowControllerAssembly
    private let configuration: UISDKConfiguration

    // MARK: Init

    init(
        coreSDK: AcquiringSdk,
        webFlowControllerAssembly: IThreeDSWebFlowControllerAssembly,
        configuration: UISDKConfiguration
    ) {
        self.coreSDK = coreSDK
        self.webFlowControllerAssembly = webFlowControllerAssembly
        self.configuration = configuration
    }

    // MARK: IAddCardControllerAssembly

    func addCardController(customerKey: String) -> IAddCardController {
        AddCardController(
            addCardService: coreSDK,
            threeDSDeviceInfoProvider: coreSDK.threeDSDeviceInfoProvider(),
            webFlowController: webFlowControllerAssembly.threeDSWebFlowController(),
            threeDSService: coreSDK,
            customerKey: customerKey,
            checkType: configuration.addCardCheckType
        )
    }
}
