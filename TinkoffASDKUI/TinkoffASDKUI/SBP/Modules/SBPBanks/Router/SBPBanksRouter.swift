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
    private let sbpPaymentSheetAssembly: ISBPPaymentSheetAssembly

    // MARK: - Initialization

    init(
        sbpBanksAssembly: ISBPBanksAssembly,
        sbpPaymentSheetAssembly: ISBPPaymentSheetAssembly
    ) {
        self.sbpBanksAssembly = sbpBanksAssembly
        self.sbpPaymentSheetAssembly = sbpPaymentSheetAssembly
    }
}

// MARK: - ISBPBanksRouter

extension SBPBanksRouter {
    func closeScreen() {
        transitionHandler?.dismiss(animated: true)
    }

    func show(banks: [SBPBank], qrPayload: GetQRPayload?) {
        let sbpModule = sbpBanksAssembly.build()
        sbpModule.input.set(qrPayload: qrPayload, banks: banks)
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

    func showPaymentSheet(paymentId: String) {
        let sbpPaymentSheetModule = sbpPaymentSheetAssembly.build()
        sbpPaymentSheetModule.input.set(paymentId: paymentId)
        transitionHandler?.present(sbpPaymentSheetModule.view, animated: true)
    }
}
