//
//  AppBasedSdkUiProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class AppBasedSdkUiProviderMock: IAppBasedSdkUiProvider {

    // MARK: - sdkInterface

    var sdkInterfaceCallsCount = 0
    var sdkInterfaceReturnValue: TdsSdkInterface!

    func sdkInterface() -> TdsSdkInterface {
        sdkInterfaceCallsCount += 1
        return sdkInterfaceReturnValue
    }

    // MARK: - sdkUiTypes

    var sdkUiTypesCallsCount = 0
    var sdkUiTypesReturnValue: [TdsSdkUiType]!

    func sdkUiTypes() -> [TdsSdkUiType] {
        sdkUiTypesCallsCount += 1
        return sdkUiTypesReturnValue
    }
}

// MARK: - Resets

extension AppBasedSdkUiProviderMock {
    func fullReset() {
        sdkInterfaceCallsCount = 0

        sdkUiTypesCallsCount = 0
    }
}
