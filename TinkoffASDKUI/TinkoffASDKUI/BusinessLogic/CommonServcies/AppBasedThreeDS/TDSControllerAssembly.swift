//
//  TDSControllerAssembly.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 10.04.2023.
//

import Foundation
import TinkoffASDKCore

protocol ITDSControllerAssembly {
    func assemble() -> ITDSController
}

final class TDSControllerAssembly: ITDSControllerAssembly {

    private let sdkConfiguration: AcquiringSdkConfiguration
    private let coreSDK: AcquiringSdk
    private let tdsWrapperBuilder: ITDSWrapperBuilder
    private let tdsCertsManager: ITDSCertsManager
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider

    init(
        sdkConfiguration: AcquiringSdkConfiguration,
        coreSDK: AcquiringSdk,
        tdsWrapperBuilder: ITDSWrapperBuilder,
        tdsCertsManager: ITDSCertsManager,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    ) {
        self.sdkConfiguration = sdkConfiguration
        self.coreSDK = coreSDK
        self.tdsWrapperBuilder = tdsWrapperBuilder
        self.tdsCertsManager = tdsCertsManager
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
    }

    func assemble() -> ITDSController {
        let tdsWrapper = tdsWrapperBuilder.build()

        return TDSController(
            threeDsService: coreSDK,
            tdsWrapper: tdsWrapper,
            tdsTimeoutResolver: TDSTimeoutResolver(),
            tdsCertsManager: tdsCertsManager,
            threeDSDeviceInfoProvider: threeDSDeviceInfoProvider,
            mainQueue: DispatchQueue.main
        )
    }
}
