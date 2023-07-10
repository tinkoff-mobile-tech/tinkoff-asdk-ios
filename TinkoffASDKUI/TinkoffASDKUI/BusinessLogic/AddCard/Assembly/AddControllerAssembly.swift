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
    private let appBasedFlowControllerAssembly: ITDSControllerAssembly
    private let configuration: UISDKConfiguration

    // MARK: Init

    init(
        coreSDK: AcquiringSdk,
        webFlowControllerAssembly: IThreeDSWebFlowControllerAssembly,
        appBasedFlowControllerAssembly: ITDSControllerAssembly,
        configuration: UISDKConfiguration
    ) {
        self.coreSDK = coreSDK
        self.webFlowControllerAssembly = webFlowControllerAssembly
        self.appBasedFlowControllerAssembly = appBasedFlowControllerAssembly
        self.configuration = configuration
    }

    // MARK: IAddCardControllerAssembly

    func addCardController(customerKey: String) -> IAddCardController {
        return AddCardController(
            addCardService: coreSDK,
            threeDSDeviceInfoProvider: coreSDK.threeDSDeviceInfoProvider(),
            webFlowController: webFlowControllerAssembly.threeDSWebFlowController(),
            threeDSService: coreSDK,
            customerKey: customerKey,
            checkType: configuration.addCardCheckType,
            tdsController: appBasedFlowControllerAssembly.assemble()
        )
    }
}
