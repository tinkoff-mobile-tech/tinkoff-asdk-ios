//
//  SBPPaymentSheetAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import TinkoffASDKCore
import UIKit

final class SBPPaymentSheetAssembly: ISBPPaymentSheetAssembly {

    // MARK: Dependencies

    private let acquiringSdk: AcquiringSdk
    private let sbpConfiguration: SBPConfiguration

    // MARK: Initialization

    init(
        acquiringSdk: AcquiringSdk,
        sbpConfiguration: SBPConfiguration
    ) {
        self.acquiringSdk = acquiringSdk
        self.sbpConfiguration = sbpConfiguration
    }

    // MARK: ISBPPaymentSheetAssembly

    func build(paymentId: String, output: ISBPPaymentSheetPresenterOutput?) -> UIViewController {
        let paymentStatusService = PaymentStatusService(acquiringSdk: acquiringSdk)
        let repeatedRequestHelper = RepeatedRequestHelper()
        let presenter = SBPPaymentSheetPresenter(
            output: output,
            paymentStatusService: paymentStatusService,
            repeatedRequestHelper: repeatedRequestHelper,
            mainDispatchQueue: DispatchQueue.main,
            sbpConfiguration: sbpConfiguration,
            paymentId: paymentId
        )

        let sheetView = CommonSheetViewController(presenter: presenter)
        presenter.view = sheetView

        let container = PullableContainerViewController(content: sheetView)
        sheetView.pullableContentDelegate = container
        return container
    }
}
