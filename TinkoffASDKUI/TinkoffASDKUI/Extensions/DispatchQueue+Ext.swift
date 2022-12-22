//
//  Dispatch+Ext.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 22.12.2022.
//

import Foundation

extension DispatchQueue {

    /// Исполняет код на Main потоке, если текущий тред не Main
    static func performOnMain(_ closure: @escaping () -> Void) {
        guard !Thread.isMainThread else {
            closure()
            return
        }

        DispatchQueue.main.async(execute: closure)
    }
}
