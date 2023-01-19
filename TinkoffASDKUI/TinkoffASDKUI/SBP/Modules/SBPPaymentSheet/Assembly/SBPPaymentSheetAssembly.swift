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

    func build(paymentId: String) -> UIViewController {
        let paymentStatusService = SBPPaymentStatusService(acquiringSdk: acquiringSdk)
        let repeatedRequestHelper = RepeatedRequestHelper(delay: .paymentStatusRequestDelay)
        let presenter = SBPPaymentSheetPresenter(
            paymentStatusService: paymentStatusService,
            repeatedRequestHelper: repeatedRequestHelper,
            sbpConfiguration: sbpConfiguration,
            paymentId: paymentId
        )

        let sheetView = CommonSheetViewController(presenter: presenter)
        presenter.view = sheetView

        return PullableContainerViewController(content: sheetView)
    }
}

// MARK: - Constants

private extension TimeInterval {
    static let paymentStatusRequestDelay: TimeInterval = 3
}
