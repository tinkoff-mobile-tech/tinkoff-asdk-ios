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
    var modelVersion: String { get }
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

    var modelVersion: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
