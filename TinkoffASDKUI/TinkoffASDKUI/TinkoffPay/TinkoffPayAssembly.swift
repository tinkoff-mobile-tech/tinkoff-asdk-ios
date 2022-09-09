//
//  TinkoffPayAssembly.swift
//  TinkoffASDKUI
//
//  Created by Serebryaniy Grigoriy on 15.04.2022.
//

import TinkoffASDKCore
import UIKit

final class TinkoffPayAssembly {
    
    private let coreSDK: AcquiringSdk
    private let tinkoffPayStatusCacheLifeTime: TimeInterval
    
    private var cachedTinkoffPayController: TinkoffPayController?
    
    init(coreSDK: AcquiringSdk,
         tinkoffPayStatusCacheLifeTime: TimeInterval) {
        self.coreSDK = coreSDK
        self.tinkoffPayStatusCacheLifeTime = tinkoffPayStatusCacheLifeTime
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
    
    var tinkoffPayController: TinkoffPayController {
        if let cachedTinkoffPayController = cachedTinkoffPayController {
            return cachedTinkoffPayController
        } else {
            let tinkoffPayController = TinkoffPayController(sdk: coreSDK,
                                                            tinkoffPayStatusCacheLifeTime: tinkoffPayStatusCacheLifeTime)
            self.cachedTinkoffPayController = tinkoffPayController
            return tinkoffPayController
        }
    }
}

private extension TinkoffPayAssembly {
    
    var paymentService: PaymentService {
        DefaultPaymentService(coreSDK: coreSDK)
    }
    
    var applicationURLOpener: URLOpener {
        ApplicationURLOpener(application: .shared)
    }
}
