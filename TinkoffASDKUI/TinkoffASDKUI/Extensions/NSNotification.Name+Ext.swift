//
//  NSNotification.Name+Ext.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 26.12.2022.
//

import Foundation

extension NSNotification.Name {

    /// linked object of type: UIUserInterfaceStyle under key: value
    static let userInterfaceStyleDidChange = Self("userInterfaceStyleDidChange")
}

extension Notification {

    struct Keys {

        static var value: String { "value" }
    }
}
