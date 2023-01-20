//
//  MainFormAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

final class MainFormAssembly: IMainFormAssembly {
    func build(stub: MainFormStub) -> UIViewController {
        let router = MainFormRouter()
        let presenter = MainFormPresenter(router: router, stub: stub)
        let viewController = MainFormViewController(presenter: presenter)
        router.transitionHandler = viewController
        presenter.view = viewController

        let pullableContainerViewController = PullableContainerViewController(content: viewController)
        return pullableContainerViewController
    }
}
