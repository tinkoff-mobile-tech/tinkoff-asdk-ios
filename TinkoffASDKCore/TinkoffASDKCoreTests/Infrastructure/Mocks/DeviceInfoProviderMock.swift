//
//  DeviceInfoProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

@testable import TinkoffASDKCore

final class DeviceInfoProviderMock: IDeviceInfoProvider {

    var model: String {
        get { return underlyingModel }
        set(value) { underlyingModel = value }
    }

    var underlyingModel = "iPhone 13 Pro Max"

    var systemName: String {
        get { return underlyingSystemName }
        set(value) { underlyingSystemName = value }
    }

    var underlyingSystemName = "iOS"

    var systemVersion: String {
        get { return underlyingSystemVersion }
        set(value) { underlyingSystemVersion = value }
    }

    var underlyingSystemVersion = "15.0"

    var modelVersion: String {
        get { return underlyingModelVersion }
        set(value) { underlyingModelVersion = value }
    }

    var underlyingModelVersion = "iPhone 13 Pro Max"
}
