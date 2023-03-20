//
//  TinkoffPaySheetAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 13.03.2023.
//

import Foundation
import TinkoffASDKCore
import UIKit

final class TinkoffPaySheetAssembly: ITinkoffPaySheetAssembly {
    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let tinkoffPayAssembly: ITinkoffPayAssembly
    private let tinkoffPayLandingAssembly: ITinkoffPayLandingAssembly

    // MARK: Init

    init(
        coreSDK: AcquiringSdk,
        tinkoffPayAssembly: ITinkoffPayAssembly,
        tinkoffPayLandingAssembly: ITinkoffPayLandingAssembly
    ) {
        self.coreSDK = coreSDK
        self.tinkoffPayAssembly = tinkoffPayAssembly
        self.tinkoffPayLandingAssembly = tinkoffPayLandingAssembly
    }

    // MARK: ITinkoffPaySheetAssembly

    func tinkoffPaySheet(paymentFlow: PaymentFlow, completion: PaymentResultCompletion?) -> UIViewController {
        let tinkoffPayController = tinkoffPayAssembly.tinkoffPayController()
        let router = TinkoffPaySheetRouter(tinkoffPayLandingAssembly: tinkoffPayLandingAssembly)

        let presenter = TinkoffPaySheetPresenter(
            router: router,
            tinkoffPayService: coreSDK,
            tinkoffPayController: tinkoffPayController,
            paymentFlow: paymentFlow,
            moduleCompletion: completion
        )

        let view = CommonSheetViewController(presenter: presenter)

        router.transitionHandler = view
        presenter.view = view
        tinkoffPayController.delegate = presenter

        return PullableContainerViewController(content: view)
    }
}
