//
//  TinkoffPayAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.03.2023.
//

import Foundation
import TinkoffASDKCore
import UIKit

final class TinkoffPayAssembly: ITinkoffPayAssembly {
    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let configuration: UISDKConfiguration

    // MARK: Init

    init(coreSDK: AcquiringSdk, configuration: UISDKConfiguration) {
        self.coreSDK = coreSDK
        self.configuration = configuration
    }

    // MARK: ITinkoffPayAssembly

    func tinkoffPayAppChecker() -> ITinkoffPayAppChecker {
        TinkoffPayAppChecker(appChecker: AppChecker())
    }

    func tinkoffPayController() -> ITinkoffPayController {
        TinkoffPayController(
            paymentService: coreSDK,
            tinkoffPayService: coreSDK,
            applicationOpener: UIApplication.shared,
            paymentStatusService: PaymentStatusService(paymentService: coreSDK),
            repeatedRequestHelper: RepeatedRequestHelper(),
            paymentStatusRetriesCount: configuration.paymentStatusRetriesCount
        )
    }
}
