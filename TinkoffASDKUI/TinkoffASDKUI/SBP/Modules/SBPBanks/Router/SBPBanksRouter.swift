//
//  SBPBanksRouter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 26.12.2022.
//

import TinkoffASDKCore
import UIKit

final class SBPBanksRouter: ISBPBanksRouter {

    // dependencies
    weak var transitionHandler: UIViewController?

    private let sbpBanksAssembly: ISBPBanksAssembly

    // MARK: - Initialization

    init(sbpBanksAssembly: ISBPBanksAssembly) {
        self.sbpBanksAssembly = sbpBanksAssembly
    }
}

// MARK: - ISBPBanksRouter

extension SBPBanksRouter {
    func closeScreen() {
        transitionHandler?.dismiss(animated: true)
    }

    func show(banks: [SBPBank]) {
        let sbpModule = sbpBanksAssembly.build()
        sbpModule.input.set(banks: banks)
        transitionHandler?.navigationController?.pushViewController(sbpModule.view, animated: true)
    }

    func showDidNotFindBankAppAlert() {
        let title = Loc.CommonAlert.SBPNoBank.title
        let message = Loc.CommonAlert.SBPNoBank.description
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let actionTitle = Loc.CommonAlert.button
        let alertAction = UIAlertAction(title: actionTitle, style: .default)
        alertVC.addAction(alertAction)
        transitionHandler?.present(alertVC, animated: true)
    }
}
