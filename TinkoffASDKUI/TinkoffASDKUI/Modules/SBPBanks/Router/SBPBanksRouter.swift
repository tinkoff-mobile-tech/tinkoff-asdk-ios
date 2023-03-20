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
    func closeScreen(completion: VoidBlock?) {
        transitionHandler?.dismiss(animated: true, completion: completion)
    }

    func show(banks: [SBPBank], qrPayload: GetQRPayload?, paymentSheetOutput: ISBPPaymentSheetPresenterOutput?) {
        let sbpModule = sbpBanksAssembly.buildPreparedModule(paymentSheetOutput: paymentSheetOutput)
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

    func showPaymentSheet(paymentId: String, output: ISBPPaymentSheetPresenterOutput?) {
        let sbpPaymentSheetViewController = sbpPaymentSheetAssembly.build(paymentId: paymentId, output: output)
        transitionHandler?.present(sbpPaymentSheetViewController, animated: true)
    }
}
