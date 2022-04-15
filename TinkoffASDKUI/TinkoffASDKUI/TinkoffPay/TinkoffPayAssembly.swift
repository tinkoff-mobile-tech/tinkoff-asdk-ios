//
//  TinkoffPayAssembly.swift
//  TinkoffASDKUI
//
//  Created by Serebryaniy Grigoriy on 15.04.2022.
//

import TinkoffASDKCore

final class TinkoffPayAssembly {
    
    private let coreSDK: AcquiringSdk
    
    init(coreSDK: AcquiringSdk) {
        self.coreSDK = coreSDK
    }
    
    func paymentPollingViewController(content: TinkoffPayPaymentViewController,
                                      configuration: AcquiringViewConfiguration,
                                      completionHandler: PaymentCompletionHandler?) -> PaymentPollingViewController<TinkoffPayPaymentViewController> {
        PaymentPollingViewController(contentViewController: content,
                                     paymentService: paymentService,
                                     configuration: configuration,
                                     completion: completionHandler)
    }
    
    func tinkoffPayPaymentViewController(acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
                                         tinkoffPayVersion: GetTinkoffPayStatusResponse.Status.Version) -> TinkoffPayPaymentViewController {
        TinkoffPayPaymentViewController(acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
                                        paymentService: paymentService,
                                        tinkoffPayController: tinkoffPayController,
                                        tinkoffPayVersion: tinkoffPayVersion,
                                        application: UIApplication.shared)
    }
}

private extension TinkoffPayAssembly {
    var paymentService: PaymentService {
        DefaultPaymentService(coreSDK: coreSDK)
    }
    
    var tinkoffPayController: TinkoffPayController {
        TinkoffPayController(sdk: coreSDK)
    }
    
    var applicationURLOpener: URLOpener {
        ApplicationURLOpener(application: .shared)
    }
}
