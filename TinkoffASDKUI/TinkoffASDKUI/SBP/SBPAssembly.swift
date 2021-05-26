//
//
//  SBPAssembly.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import TinkoffASDKCore

final class SBPAssembly {
    
    private let coreSDK: AcquiringSdk
    private let style: Style
    
    init(coreSDK: AcquiringSdk,
         style: Style) {
        self.coreSDK = coreSDK
        self.style = style
    }
    
    func urlPaymentViewController(paymentSource: PaymentSource,
                                  configuration: AcquiringViewConfiguration) -> SBPUrlPaymentViewController {
        SBPUrlPaymentViewController(paymentSource: paymentSource,
                                    sbpBanksService: banksService,
                                    sbpApplicationService: applicationService,
                                    sbpPaymentService: paymentService,
                                    banksListViewController: banksListViewController,
                                    configuration: configuration)
    }
    
    func noAvailableBanksViewController() -> SBPNoAvailableBanksViewController {
        SBPNoAvailableBanksViewController(style: .init(confirmButtonStyle: style.bigButtonStyle))
    }
}

private extension SBPAssembly {
    var banksService: SBPBanksService {
        DefaultSBPBanksService(coreSDK: coreSDK)
    }
    
    var applicationService: SBPApplicationService {
        DefaultSBPApplicationService(application: UIApplication.shared)
    }
    
    var paymentService: SBPPaymentService {
        DefaultSBPPaymentService(coreSDK: coreSDK)
    }
    
    var banksListViewController: SBPBankListViewController {
        SBPBankListViewController(style: .init(continueButtonStyle: style.bigButtonStyle),
                                  tableManager: banksListTableManager)
    }
    
    var banksListTableManager: SBPBankListTableManager {
        SBPBankListTableManager(cellImageLoader: cellImageLoader)
    }
    
    var cellImageLoader: CellImageLoader {
        CellImageLoader(imageLoader: ImageLoader())
    }
}
