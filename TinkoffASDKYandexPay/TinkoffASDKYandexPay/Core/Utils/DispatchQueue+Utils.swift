//
//  DispatchQueue+Utils.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 22.12.2022.
//

import Foundation

extension DispatchQueue {
    static func performOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
