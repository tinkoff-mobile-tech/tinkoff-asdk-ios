//
//  DeviceInfoProvider.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation
import class UIKit.UIDevice

protocol IDeviceInfoProvider {
    var model: String { get }
    var systemName: String { get }
    var systemVersion: String { get }
}

final class DeviceInfoProvider: IDeviceInfoProvider {
    var model: String {
        UIDevice.current.localizedModel
    }

    var systemName: String {
        UIDevice.current.systemName
    }

    var systemVersion: String {
        UIDevice.current.systemVersion
    }
}
