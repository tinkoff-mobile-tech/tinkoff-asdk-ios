//
//  ThreeDSDeviceInfoProviderBuilderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 31.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class ThreeDSDeviceParamsProviderBuilderMock: IThreeDSDeviceParamsProviderBuilder {

    // MARK: - threeDSDeviceInfoProvider

    var threeDSDeviceInfoProviderCallsCount = 0
    var threeDSDeviceInfoProviderReturnValue: IThreeDSDeviceInfoProvider!

    func threeDSDeviceInfoProvider() -> IThreeDSDeviceInfoProvider {
        threeDSDeviceInfoProviderCallsCount += 1
        return threeDSDeviceInfoProviderReturnValue
    }
}

// MARK: - Resets

extension ThreeDSDeviceParamsProviderBuilderMock {
    func fullReset() {
        threeDSDeviceInfoProviderCallsCount = 0
    }
}
