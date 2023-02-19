//
//
//  PaymentControllerAssembly.swift
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

import Foundation
import TinkoffASDKCore

protocol IPaymentControllerAssembly {
    func paymentController() -> PaymentController
}

final class PaymentControllerAssembly: IPaymentControllerAssembly {
    private let coreSDK: AcquiringSdk
    private let threeDSWebFlowAssembly: IThreeDSWebFlowControllerAssembly
    private let sdkConfiguration: AcquiringSdkConfiguration
    private let uiSDKConfiguration: UISDKConfiguration

    init(
        coreSDK: AcquiringSdk,
        threeDSWebFlowAssembly: IThreeDSWebFlowControllerAssembly,
        sdkConfiguration: AcquiringSdkConfiguration,
        uiSDKConfiguration: UISDKConfiguration
    ) {
        self.coreSDK = coreSDK
        self.threeDSWebFlowAssembly = threeDSWebFlowAssembly
        self.sdkConfiguration = sdkConfiguration
        self.uiSDKConfiguration = uiSDKConfiguration
    }

    func paymentController() -> PaymentController {
        let uiSDK = AcquiringUISDK(
            coreSDK: coreSDK,
            configuration: sdkConfiguration,
            uiSDKConfiguration: uiSDKConfiguration
        )

        let paymentStatusService = PaymentStatusService(acquiringSdk: coreSDK)
        let repeatedRequestHelper = RepeatedRequestHelper(delay: .paymentStatusRequestDelay)
        let paymentStatusUpdateService = PaymentStatusUpdateService(
            paymentStatusService: paymentStatusService,
            repeatedRequestHelper: repeatedRequestHelper,
            maxRequestRepeatCount: uiSDKConfiguration.paymentStatusRetriesCount
        )

        return PaymentController(
            paymentFactory: paymentFactory(acquiringSDK: coreSDK),
            threeDSWebFlowController: threeDSWebFlowAssembly.threeDSWebFlowController(),
            threeDSService: coreSDK,
            threeDSDeviceInfoProvider: coreSDK.threeDSDeviceInfoProvider(),
            tdsController: uiSDK.tdsController,
            paymentStatusUpdateService: paymentStatusUpdateService,
            acquiringUISDK: uiSDK
        )
    }
}

private extension PaymentControllerAssembly {
    func paymentFactory(acquiringSDK: AcquiringSdk) -> PaymentFactory {
        return PaymentFactory(
            paymentsService: acquiringSDK,
            threeDsService: acquiringSDK,
            threeDSDeviceInfoProvider: acquiringSDK.threeDSDeviceInfoProvider(),
            ipProvider: acquiringSDK.ipAddressProvider
        )
    }
}

// MARK: - Constants

private extension TimeInterval {
    static let paymentStatusRequestDelay: TimeInterval = 3
}
