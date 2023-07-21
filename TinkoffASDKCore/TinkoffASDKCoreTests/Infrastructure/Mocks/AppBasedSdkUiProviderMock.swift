//
//  AppBasedSdkUiProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

public final class AppBasedSdkUiProviderMock: IAppBasedSdkUiProvider {
    public init() {}

    // MARK: - sdkInterface

    public var sdkInterfaceCallsCount = 0
    public var sdkInterfaceReturnValue: TdsSdkInterface!

    public func sdkInterface() -> TdsSdkInterface {
        sdkInterfaceCallsCount += 1
        return sdkInterfaceReturnValue
    }

    // MARK: - sdkUiTypes

    public var sdkUiTypesCallsCount = 0
    public var sdkUiTypesReturnValue: [TdsSdkUiType]!

    public func sdkUiTypes() -> [TdsSdkUiType] {
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
