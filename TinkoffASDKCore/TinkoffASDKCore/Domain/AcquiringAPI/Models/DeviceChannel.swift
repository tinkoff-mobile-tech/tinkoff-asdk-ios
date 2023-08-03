//
//  DeviceChannel.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 01.08.2023.
//

import Foundation

public enum DeviceChannel: String {
    /// Application (APP)
    case appSdk = "01"
    /// Browser (BRW)
    case browser = "02"

    static func create(from data: FinishAuthorizeDataEnum?) -> String? {
        guard let data = data else { return nil }
        switch data {
        case .threeDsBrowser:
            return Self.browser.rawValue
        case .threeDsSdk:
            return Self.appSdk.rawValue
        case .dictionary:
            return nil
        }
    }
}
