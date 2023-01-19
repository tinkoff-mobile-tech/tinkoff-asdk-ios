//
//  SBPPaymentSheetAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import Foundation
import TinkoffASDKCore

typealias SBPPaymentSheetModule = Module<SBPPaymentSheetModuleInput>

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

    func build() -> SBPPaymentSheetModule {
        let paymentStatusService = SBPPaymentStatusService(acquiringSdk: acquiringSdk)
        let repeatedRequestHelper = RepeatedRequestHelper(delay: .paymentStatusRequestDelay)
        let presenter = SBPPaymentSheetPresenter(
            paymentStatusService: paymentStatusService,
            repeatedRequestHelper: repeatedRequestHelper,
            sbpConfiguration: sbpConfiguration
        )

        let sheetView = CommonSheetViewController(presenter: presenter)
        presenter.view = sheetView

        let view = PullableContainerViewController(content: sheetView)

        return Module(view: view, input: presenter)
    }
}

// MARK: - Constants

private extension TimeInterval {
    static let paymentStatusRequestDelay: TimeInterval = 3
}
