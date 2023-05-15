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
    private let configuration: UISDKConfiguration

    // MARK: Initialization

    init(
        acquiringSdk: AcquiringSdk,
        configuration: UISDKConfiguration
    ) {
        self.acquiringSdk = acquiringSdk
        self.configuration = configuration
    }

    // MARK: ISBPPaymentSheetAssembly

    func build(paymentId: String, output: ISBPPaymentSheetPresenterOutput?) -> UIViewController {
        let paymentStatusService = PaymentStatusService(paymentService: acquiringSdk)
        let repeatedRequestHelper = RepeatedRequestHelper()
        let presenter = SBPPaymentSheetPresenter(
            output: output,
            paymentStatusService: paymentStatusService,
            repeatedRequestHelper: repeatedRequestHelper,
            mainDispatchQueue: DispatchQueue.main,
            requestRepeatCount: configuration.paymentStatusRetriesCount,
            paymentId: paymentId
        )

        let sheetView = CommonSheetViewController(presenter: presenter)
        presenter.view = sheetView

        let container = PullableContainerViewController(content: sheetView)
        sheetView.pullableContentDelegate = container
        return container
    }
}
