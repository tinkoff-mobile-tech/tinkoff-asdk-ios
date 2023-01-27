//
//  MainFormAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import TinkoffASDKCore
import UIKit

final class MainFormAssembly: IMainFormAssembly {
    private let coreSDK: AcquiringSdk

    init(coreSDK: AcquiringSdk) {
        self.coreSDK = coreSDK
    }

    func build(
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        stub: MainFormStub
    ) -> UIViewController {
        let router = MainFormRouter(configuration: configuration)

        let presenter = MainFormPresenter(
            router: router,
            coreSDK: coreSDK,
            paymentFlow: paymentFlow,
            configuration: configuration,
            stub: stub
        )

        let viewController = MainFormViewController(presenter: presenter)

        router.transitionHandler = viewController
        presenter.view = viewController

        let pullableContainerViewController = PullableContainerViewController(content: viewController)
        return pullableContainerViewController
    }
}
